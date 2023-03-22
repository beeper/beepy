#include <linux/module.h>
#include <linux/mutex.h>
#include <linux/slab.h>
#include <linux/spinlock.h>
#include <linux/workqueue.h>
#include <linux/spi/spi.h>

#include <linux/kthread.h> 
#include <linux/sched.h>
#include <linux/delay.h>
#include <linux/time.h>
#include <linux/timer.h>

#include <linux/fb.h>
#include <linux/mm.h>
#include <linux/init.h>
#include <linux/vmalloc.h>

#include <linux/gpio.h>
#include <linux/uaccess.h>

#define LCDWIDTH 400
#define VIDEOMEMSIZE    (1*1024*1024)   /* 1 MB */

char commandByte = 0b10000000;
char vcomByte    = 0b01000000;
char clearByte   = 0b00100000;
char paddingByte = 0b00000000;

char DISP       = 22;
char SCS        = 8;
char VCOM       = 23;

int lcdWidth = LCDWIDTH;
int lcdHeight = 240;
int fpsCounter;

static int seuil = 4; // Indispensable pour fbcon
module_param(seuil, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IWGRP );

char vcomState;

unsigned char lineBuffer[LCDWIDTH/8];

struct sharp {
    struct spi_device	*spi;
	int			id;
    char			name[sizeof("sharp-3")];

    struct mutex		mutex;
	struct work_struct	work;
	spinlock_t		lock;
};

struct sharp   *screen;
struct fb_info *info;

static void *videomemory;
static u_long videomemorysize = VIDEOMEMSIZE;

void vfb_fillrect(struct fb_info *p, const struct fb_fillrect *region);
static int vfb_mmap(struct fb_info *info, struct vm_area_struct *vma);
void sendLine(char *buffer, char lineNumber);

static struct fb_var_screeninfo vfb_default = {
    .xres =     400,
    .yres =     240,
    .xres_virtual = 400,
    .yres_virtual = 240,
    .bits_per_pixel = 24,
    .grayscale = 1,
    .red =      { 0, 8, 0 },
    .green =    { 0, 8, 0 },
    .blue =     { 0, 8, 0 },
    .activate = FB_ACTIVATE_NOW,
    .height =   400,
    .width =    240,
    .pixclock = 20000,
    .left_margin =  0,
    .right_margin = 0,
    .upper_margin = 0,
    .lower_margin = 0,
    .hsync_len =    128,
    .vsync_len =    128,
    .vmode =    FB_VMODE_NONINTERLACED,
    };

static struct fb_fix_screeninfo vfb_fix = {
    .id =       "Sharp FB",
    .type =     FB_TYPE_PACKED_PIXELS,
    .line_length = 1200,
    .xpanstep = 0,
    .ypanstep = 0,
    .ywrapstep =    0,
    .visual =	FB_VISUAL_MONO10,
    .accel =    FB_ACCEL_NONE,
};

static struct fb_ops vfb_ops = {
    .fb_read        = fb_sys_read,
    .fb_write       = fb_sys_write,
    .fb_fillrect    = sys_fillrect,
    .fb_copyarea    = sys_copyarea,
    .fb_imageblit   = sys_imageblit,
    .fb_mmap    = vfb_mmap,
};

static struct task_struct *thread1;
static struct task_struct *fpsThread;
static struct task_struct *vcomToggleThread;

static int vfb_mmap(struct fb_info *info,
            struct vm_area_struct *vma)
{
    unsigned long start = vma->vm_start;
    unsigned long size = vma->vm_end - vma->vm_start;
    unsigned long offset = vma->vm_pgoff << PAGE_SHIFT;
    unsigned long page, pos;
    printk(KERN_CRIT "start %ld size %ld offset %ld", start, size, offset);

    if (vma->vm_pgoff > (~0UL >> PAGE_SHIFT))
        return -EINVAL;
    if (size > info->fix.smem_len)
        return -EINVAL;
    if (offset > info->fix.smem_len - size)
        return -EINVAL;

    pos = (unsigned long)info->fix.smem_start + offset;

    while (size > 0) {
        page = vmalloc_to_pfn((void *)pos);
        if (remap_pfn_range(vma, start, page, PAGE_SIZE, PAGE_SHARED)) {
            return -EAGAIN;
        }
        start += PAGE_SIZE;
        pos += PAGE_SIZE;
        if (size > PAGE_SIZE)
            size -= PAGE_SIZE;
        else
            size = 0;
    }

    return 0;
}

void vfb_fillrect(struct fb_info *p, const struct fb_fillrect *region)
{
    printk(KERN_CRIT "from fillrect");
}

static void *rvmalloc(unsigned long size)
{
    void *mem;
    unsigned long adr;

    size = PAGE_ALIGN(size);
    mem = vmalloc_32(size);
    if (!mem)
        return NULL;

    memset(mem, 0, size); /* Clear the ram out, no junk to the user */
    adr = (unsigned long) mem;
    while (size > 0) {
        SetPageReserved(vmalloc_to_page((void *)adr));
        adr += PAGE_SIZE;
        size -= PAGE_SIZE;
    }

    return mem;
}

static void rvfree(void *mem, unsigned long size)
{
    unsigned long adr;

    if (!mem)
        return;

    adr = (unsigned long) mem;
    while ((long) size > 0) {
        ClearPageReserved(vmalloc_to_page((void *)adr));
        adr += PAGE_SIZE;
        size -= PAGE_SIZE;
    }
    vfree(mem);
}

void clearDisplay(void) {
    char buffer[2] = {clearByte, paddingByte};
    gpio_set_value(SCS, 1);

    spi_write(screen->spi, (const u8 *)buffer, 2);

    gpio_set_value(SCS, 0);
}

char reverseByte(char b) {
  b = (b & 0xF0) >> 4 | (b & 0x0F) << 4;
  b = (b & 0xCC) >> 2 | (b & 0x33) << 2;
  b = (b & 0xAA) >> 1 | (b & 0x55) << 1;
  return b;
}

int vcomToggleFunction(void* v) 
{
    while (!kthread_should_stop()) 
    {
        msleep(50);
        vcomState = vcomState ? 0:1;
        gpio_set_value(VCOM, vcomState);
    }
    return 0;
}

int fpsThreadFunction(void* v)
{
    while (!kthread_should_stop()) 
    {
        msleep(5000);
    	printk(KERN_DEBUG "FPS sharp : %d\n", fpsCounter);
    	fpsCounter = 0;
    }
    return 0;
}

int thread_fn(void* v) 
{
    //int i;
    int x,y,i;
    char pixel;
    char hasChanged = 0;

    unsigned char *screenBufferCompressed;
    char bufferByte = 0;
    char sendBuffer[1 + (1+50+1)*1 + 1];

    clearDisplay();

    //unsigned char *screenBufferCompressed;
    screenBufferCompressed = vzalloc((50+4)*240*sizeof(unsigned char)); 	//plante si on met moins

    //char bufferByte = 0;
    //char sendBuffer[1 + (1+50+1)*1 + 1];
    sendBuffer[0] = commandByte;
    sendBuffer[52] = paddingByte;
    sendBuffer[1 + 52] = paddingByte;

    // Init screen to black
    for(y=0 ; y < 240 ; y++)
    {
	gpio_set_value(SCS, 1);
	screenBufferCompressed[y*(50+4)] = commandByte;
	screenBufferCompressed[y*(50+4) + 1] = reverseByte(y+1); //sharp display lines are indexed from 1
	screenBufferCompressed[y*(50+4) + 52] = paddingByte;
	screenBufferCompressed[y*(50+4) + 53] = paddingByte;

	//screenBufferCompressed is all to 0 by default (vzalloc)

	spi_write(screen->spi, (const u8 *)(screenBufferCompressed+(y*(50+4))), 54);
	gpio_set_value(SCS, 0);
    }

    // Main loop
    while (!kthread_should_stop()) 
    {
        msleep(50);

        for(y=0 ; y < 240 ; y++)
        {
            hasChanged = 0;

            for(x=0 ; x<50 ; x++)
            {
                for(i=0 ; i<8 ; i++ )
                {
                    pixel = ioread8((void*)((uintptr_t)info->fix.smem_start + (x*8 + y*400 + i)*3));

                    if(pixel)
                    {
                        // passe le bit 7 - i a 1
                        bufferByte |=  (1 << (7 - i)); 
                    }
                    else
                    {
                        // passe le bit 7 - i a 0
                        bufferByte &=  ~(1 << (7 - i)); 
                    }
                }
                if(!hasChanged && (screenBufferCompressed[x + 2 + y*(50+4)] != bufferByte))
                {
                    hasChanged = 1;
                }
                screenBufferCompressed[x+2 + y*(50+4)] = bufferByte;
            }

            if(hasChanged)
            {
                gpio_set_value(SCS, 1);
                //la memoire allouee avec vzalloc semble trop lente...
                memcpy(sendBuffer, screenBufferCompressed+y*(50+4), 54);
                spi_write(screen->spi, (const u8 *)(sendBuffer), 54);
                gpio_set_value(SCS, 0);
            }

        }
    }

    return 0;
}

static int sharp_probe(struct spi_device *spi)
{
    char our_thread[] = "updateScreen";
    char thread_vcom[] = "vcom";
    char thread_fps[] = "fpsThread";
    int retval;

	screen = devm_kzalloc(&spi->dev, sizeof(*screen), GFP_KERNEL);
	if (!screen)
		return -ENOMEM;

	spi->bits_per_word  = 8;
	spi->max_speed_hz   = 2000000;

	screen->spi	= spi;

    spi_set_drvdata(spi, screen);

    thread1 = kthread_create(thread_fn,NULL,our_thread);
    if((thread1))
    {
        wake_up_process(thread1);
    }

    fpsThread = kthread_create(fpsThreadFunction,NULL,thread_fps);
    if((fpsThread))
    {
        wake_up_process(fpsThread);
    }

    vcomToggleThread = kthread_create(vcomToggleFunction,NULL,thread_vcom);
    if((vcomToggleThread))
    {
        wake_up_process(vcomToggleThread);
    }

    gpio_request(SCS, "SCS");
    gpio_direction_output(SCS, 0);

    gpio_request(VCOM, "VCOM");
    gpio_direction_output(VCOM, 0);

    gpio_request(DISP, "DISP");
    gpio_direction_output(DISP, 1);

    // SCREEN PART
    retval = -ENOMEM;

    if (!(videomemory = rvmalloc(videomemorysize)))
        return retval;

    memset(videomemory, 0, videomemorysize);

    info = framebuffer_alloc(sizeof(u32) * 256, &spi->dev);
    if (!info)
        goto err;

    info->screen_base = (char __iomem *)videomemory;
    info->fbops = &vfb_ops;

    info->var = vfb_default;
    vfb_fix.smem_start = (unsigned long) videomemory;
    vfb_fix.smem_len = videomemorysize;
    info->fix = vfb_fix;
    info->par = NULL;
    info->flags = FBINFO_FLAG_DEFAULT;

    retval = fb_alloc_cmap(&info->cmap, 16, 0);
    if (retval < 0)
        goto err1;

    retval = register_framebuffer(info);
    if (retval < 0)
        goto err2;

    fb_info(info, "Virtual frame buffer device, using %ldK of video memory\n",
        videomemorysize >> 10);
    return 0;
err2:
    fb_dealloc_cmap(&info->cmap);
err1:
    framebuffer_release(info);
err:
    rvfree(videomemory, videomemorysize);

    return 0;
}

static int sharp_remove(struct spi_device *spi)
{
        if (info) {
                unregister_framebuffer(info);
                fb_dealloc_cmap(&info->cmap);
                framebuffer_release(info);
        }
	kthread_stop(thread1);
	kthread_stop(fpsThread);
    kthread_stop(vcomToggleThread);
	printk(KERN_CRIT "out of screen module");
	return 0;
}

static struct spi_driver sharp_driver = {
    .probe          = sharp_probe,
    .remove         = sharp_remove,
	.driver = {
		.name	= "sharp",
		.owner	= THIS_MODULE,
	},
};

module_spi_driver(sharp_driver);

MODULE_AUTHOR("Ael Gain <ael.gain@free.fr>");
MODULE_DESCRIPTION("Sharp memory lcd driver");
MODULE_LICENSE("GPL v2");
MODULE_ALIAS("spi:sharp");
