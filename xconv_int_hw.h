// ==============================================================
// File generated by Vivado(TM) HLS - High-Level Synthesis from C, C++ and SystemC
// Version: 2018.2
// Copyright (C) 1986-2018 Xilinx, Inc. All Rights Reserved.
// 
// ==============================================================

// CTRL_BUS
// 0x00 : Control signals
//        bit 0  - ap_start (Read/Write/COH)
//        bit 1  - ap_done (Read/COR)
//        bit 2  - ap_idle (Read)
//        bit 3  - ap_ready (Read)
//        bit 7  - auto_restart (Read/Write)
//        others - reserved
// 0x04 : Global Interrupt Enable Register
//        bit 0  - Global Interrupt Enable (Read/Write)
//        others - reserved
// 0x08 : IP Interrupt Enable Register (Read/Write)
//        bit 0  - Channel 0 (ap_done)
//        bit 1  - Channel 1 (ap_ready)
//        others - reserved
// 0x0c : IP Interrupt Status Register (Read/TOW)
//        bit 0  - Channel 0 (ap_done)
//        bit 1  - Channel 1 (ap_ready)
//        others - reserved
// 0x80 : Data signal of image_width
//        bit 31~0 - image_width[31:0] (Read/Write)
// 0x84 : reserved
// 0x88 : Data signal of image_height
//        bit 31~0 - image_height[31:0] (Read/Write)
// 0x8c : reserved
// 0x40 ~
// 0x7f : Memory 'kernel' (9 * 32b)
//        Word n : bit [31:0] - kernel[n]
// (SC = Self Clear, COR = Clear on Read, TOW = Toggle on Write, COH = Clear on Handshake)

#define XCONV_INT_CTRL_BUS_ADDR_AP_CTRL           0x00
#define XCONV_INT_CTRL_BUS_ADDR_GIE               0x04
#define XCONV_INT_CTRL_BUS_ADDR_IER               0x08
#define XCONV_INT_CTRL_BUS_ADDR_ISR               0x0c
#define XCONV_INT_CTRL_BUS_ADDR_IMAGE_WIDTH_DATA  0x80
#define XCONV_INT_CTRL_BUS_BITS_IMAGE_WIDTH_DATA  32
#define XCONV_INT_CTRL_BUS_ADDR_IMAGE_HEIGHT_DATA 0x88
#define XCONV_INT_CTRL_BUS_BITS_IMAGE_HEIGHT_DATA 32
#define XCONV_INT_CTRL_BUS_ADDR_KERNEL_BASE       0x40
#define XCONV_INT_CTRL_BUS_ADDR_KERNEL_HIGH       0x7f
#define XCONV_INT_CTRL_BUS_WIDTH_KERNEL           32
#define XCONV_INT_CTRL_BUS_DEPTH_KERNEL           9
