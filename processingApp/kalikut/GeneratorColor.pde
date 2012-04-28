//einen FARBGENERATOR hast (Rainbow, rainbow soli, solid, fire, rgb color)

private static final int GEN_COL_RAINBOW = 1;
private static final int GEN_COL_RAINBOW_SOLID = 2;
private static final int GEN_COL_SOLID = 3;
private static final int GEN_COL_FIRE = 4;
private static final int GEN_COL_RGBCOL = 5;
private static final int GEN_COL_PLASMA = 6;
private static final int GEN_COL_PULSE = 7;
private static final int GEN_COL_SLIDER = 8;
private static final int GEN_COL_GLACE = 9;
private static final int GEN_COL_XXX = 10;

private static final int MAX_COLOR = 10;

private static final int FIRE_BUFFER = 4;

private int[] fireColors;
private int[] fireBuffer;
private int[] rgbColBuffer = new int[NR_OF_PIXELS_X];
private int[] plasma = new int [100];
private float plasmaX=0, plasmaY=0;


void generateColor() {
  if (genColor==GEN_COL_FIRE) {
    updateFireBuffer();
  }

  ColorSet cs = colorSet.get(colSet);

  if (frame%globalDelayInv==0) {
    for (int x=0; x<NR_OF_PIXELS_X; x++) {

      int rnd = int(random(3));
      switch (rnd) {
      case 0: 
        rgbColBuffer[x] = cs.getC1();
        break;

      case 1: 
        rgbColBuffer[x] = cs.getC2();
        break;

      default:
        rgbColBuffer[x] = cs.getC3();
        break;
      }
    }
  }

  int globalDelayLocal = globalDelay/2;
  float globalDelayPlasma = globalDelay/400.0f;
  plasmaY+=globalDelayPlasma;

  for (int x=0; x<NR_OF_PIXELS_X; x++) {
    for (int y=0; y<NR_OF_PIXELS_Y; y++) {
      int i = y*NR_OF_PIXELS_X+x;

      switch(genColor) {
      case GEN_COL_RAINBOW: //Rainbow
        colorArray[i]=mul(cs, (frame+x+y<<1)*globalDelayLocal);
        break;

      case GEN_COL_RAINBOW_SOLID: //Rainbow Solid
        colorArray[i]=mul(cs, frame*globalDelayLocal);
        break;

      case GEN_COL_SOLID: //Solid
        colorArray[i] = color(255, 255, 255);
        break;

      case GEN_COL_FIRE:
        int fireOfs = y*(NR_OF_PIXELS_X+FIRE_BUFFER)+x+FIRE_BUFFER;
        colorArray[i] = fireColors[ fireBuffer[fireOfs] ];
        break;

      case GEN_COL_RGBCOL:
        colorArray[i] = rgbColBuffer[x];
        break;

      case GEN_COL_PLASMA:
        float ypi = y*PI;
        float xpi = x*PI/globalDelayLocal;
        int c=int(sin(ypi+plasmaY)*16+sin(ypi*1.5f+PI/6+plasmaY)*16+cos(xpi+plasmaX)*16+cos(xpi*2f+PI/2+plasmaX)*25)+32;
        c=constrain(c, 0, 99);
        colorArray[i]=plasma[c];
        plasmaX+=globalDelayPlasma;
        break;

      case GEN_COL_PULSE:
        colorArray[i]=mul(cs, (frame+x+y<<1)*globalDelayLocal);
        break;

      case GEN_COL_SLIDER:
        int ofs = i+frame;
        int xorR = i*ofs; 
        int xorB = (i*ofs)^frame;
        int xorG = (xorR+xorB)>>1;
        colorArray[i]=mul(cs, (globalDelay*(xorR))>>6);
        //        colorArray[i]=color(xorR, xorG, xorB);
        break;

      case GEN_COL_GLACE:
        //TODO
        break;

      case GEN_COL_XXX:        
        ofs = i+frame;
        xorR = (frame|ofs)%256; 
        xorG = (frame*i)%256;
        xorB = ((i*ofs)^ofs)%256;

        //        int xorR = ((i*frame)^ofs)%256;
        //        int xorG = (ofs^i)%256;
        //        int xorB = (ofs^frame)%256;
        colorArray[i]=color(xorR, xorG, xorB);
        break;
      }
    }
  }
}


void setupColor() {
  //setup fire
  fireColors = new int[256];
  fireBuffer = new int[(NR_OF_PIXELS_X+FIRE_BUFFER)*NR_OF_PIXELS_Y];

  for (int i = 0; i < 32; ++i) {
    /* black to blue, 32 values*/
    fireColors[i]=color(i<<1, 0, 0);

    /* blue to red, 32 values*/
    fireColors[i + 32]=color(i << 3, 0, 64 - (i << 1));

    /*red to yellow, 32 values*/
    fireColors[i + 64]=color(255, i << 3, 0);

    /* yellow to white, 162 */
    fireColors[i + 96]=color(255, 255, i << 2);
    fireColors[i + 128]=color(255, 255, 64+(i << 2));
    fireColors[i + 160]=color(255, 255, 128+(i << 2));
    fireColors[i + 192]=color(255, 255, 192+i);
    fireColors[i + 224]=color(255, 255, 224+i);
  }

  //setup plasma lut
  int i;
  float s1, s2, s3;
  for (i=0;i<50;i++) {
    s1=sin(i*PI/50);
    s2=sin(i*PI/50+PI/4);
    s3=sin(i*PI/50+PI/2);
    plasma[i]=color(128+s1*128, 128+s2*128, 0);
  }
  for (i=50;i<100;i++) {
    s1=sin(i*PI/50);
    s2=sin(i*PI/50+PI/4);
    s3=sin(i*PI/50+PI/2);
    plasma[i]=color(128+s1*128, 64+s2*128, 128+s3*128);
  }
}


//fire fx
void updateFireBuffer() {
  int ofs;
  int localRnd = globalDelay;
  //seed
  for (int y=0; y<NR_OF_PIXELS_Y; y++) {
    ofs = y*(NR_OF_PIXELS_X+FIRE_BUFFER);
    int rnd = int(random(globalDelay));
    /* the lower the value, the intense the fire, compensate a lower value with a higher decay value*/
    if (rnd > globalDelay/2) {
      fireBuffer[ofs] = 255;
    } 
    else {
      fireBuffer[ofs] = 0;
    }
  }

  int yOfsMinusOneLine=0;
  //calculate
  for (int y=0; y<NR_OF_PIXELS_Y; y++) {
    ofs = y*(NR_OF_PIXELS_X+FIRE_BUFFER);
    for (int x=0; x<FIRE_BUFFER+NR_OF_PIXELS_X-1; x++) {
      //calculate average for current y line
      int a = (fireBuffer[ofs+x] + fireBuffer[ofs+x+1])/2;

      //additional calculations      
      if (y>0) {
        a += (fireBuffer[yOfsMinusOneLine+x] + fireBuffer[yOfsMinusOneLine+x+1])/2;
        a/=2;
      }

      //decay
      if (a>1) {
        a--;
      }
      fireBuffer[ofs+x+1]=a;
    }
    yOfsMinusOneLine = ofs;
  }
}

