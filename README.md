# FPGA-GPU


This project is a work in progress attempting to create a simple GPU using a low-budget FPGA while still having the fundemental structure designs of modern GPUs.

Continuation of my project [FPGA-PPU](https://github.com/JamesG321/FPGA-Pixel-Processing-Unit), where I built a Pixel Processing Unit (PPU) on an FPGA board. The PPU is used by the Nintendo Entertainment System for graphic processing and was revolutionary at its time. This project aims to create hardware that can do real-time graphic processing instead of drawing sprites, at the end goal of creating 3D graphics using modern computer graphic principles.



## Getting Started

This project is built on the Altera De1-SoC-MLT2 Board. Download the .sv files and compile them on Quartus II, the Altera IDE
to run the program properly.

### Prerequisites

Proper installation of Quartus II/[Quartus Prime](https://www.altera.com/downloads/download-center.html)

[Altera De1-SoC-MLT2 Board](https://www.altera.com/content/dam/altera-www/global/en_US/portal/dsn/42/doc-us-dsnbk-42-4207350307415-de1-soc-mtl2-user-manual.pdf)

See my previous project [FPGA-PPU](https://github.com/JamesG321/FPGA-Pixel-Processing-Unit) to have a better understanding of how vga protocols and pixels are rendered on the screen. 

## Built With

* [Quartus Prime](https://www.altera.com/downloads/download-center.html)

## Versioning

Work in progress. Currently implementing GPU math functions (rotation, 3D-2D perspective transform etc.) in GPU functions.sv


## Authors

* **James Guo** - [GitHub](https://github.com/JamesG321)
