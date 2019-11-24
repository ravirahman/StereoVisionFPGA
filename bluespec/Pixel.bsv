import Vector::*;

typedef Vector#(pd, UInt#(pixelWidth)) Pixel#(numeric type pd, numeric type pixelWidth);


function Pixel#(4, pixelWidth) mkRGBPixel(UInt#(pixelWidth) r, UInt#(pixelWidth) g, UInt#(pixelWidth) b);
    Pixel#(4, pixelWidth) pixel;
    pixel[0] = r;
    pixel[1] = g;
    pixel[2] = b;
    pixel[3] = 0;
    return pixel;
endfunction

function Pixel#(4, pixelWidth)  mkRGBAPixel(UInt#(pixelWidth) r, UInt#(pixelWidth) g, UInt#(pixelWidth) b, UInt#(pixelWidth) a);
    Pixel#(4, pixelWidth) pixel;
    pixel[0] = r;
    pixel[1] = g;
    pixel[2] = b;
    pixel[3] = a;
    return pixel;
endfunction

function Pixel#(1, pixelWidth) mkGreyscalePixel(UInt#(pixelWidth) x);
    Pixel#(1, pixelWidth) pixel;
    pixel[0] = x;
    return pixel;
endfunction
