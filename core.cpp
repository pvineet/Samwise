#include "core.h"


void conv_int(int input_image[width*height], int output_image[width*height], int kernel[kernel_dim*kernel_dim], int image_width, int image_height){
#pragma HLS INTERFACE s_axilite port=image_height bundle=CTRL_BUS
#pragma HLS INTERFACE s_axilite port=image_width bundle=CTRL_BUS
#pragma HLS INTERFACE bram port=output_image
#pragma HLS INTERFACE bram port=input_image
#pragma HLS INTERFACE s_axilite port=return bundle=CTRL_BUS
#pragma HLS INTERFACE s_axilite port=kernel bundle=CTRL_BUS
int loop_count = 0;
	for(int row = 0; row < image_height-kernel_dim_2; row++){
		for(int col = 0; col < image_width-kernel_dim_2; col++){
			int res = 0;
			for(int i = 0; i < kernel_dim; i++){
				for(int j = 0; j < kernel_dim; j++){
					//#pragma HLS PIPELINE
					//#pragma HLS UNROLL factor=3
					res += input_image[((row+i)*image_width)+col+j]*kernel[i*kernel_dim+j];
					loop_count += 1;
					if(loop_count == (kernel_dim*kernel_dim)*(image_width-kernel_dim+1)*(image_height-kernel_dim+1))break;
				}
				if(loop_count == (kernel_dim*kernel_dim)*(image_width-kernel_dim+1)*(image_height-kernel_dim+1))break;
			}
			output_image[row*(image_width-kernel_dim_2)+col] = res;
			if(loop_count == (kernel_dim*kernel_dim)*(image_width-kernel_dim+1)*(image_height-kernel_dim+1))break;
		}
		if(loop_count == (kernel_dim*kernel_dim)*(image_width-kernel_dim+1)*(image_height-kernel_dim+1))break;
	}
}
