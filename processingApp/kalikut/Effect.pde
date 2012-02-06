int MAX_EFFECT=9;

private int[] fireColors;
private int[] fireBuffer;

//plasma code ripped from http://www.openprocessing.org/visuals/?visualID=10148
private int[] plasmaPal=new int[128];
private int[] cls;

void initGenerator() {
  //---------------------------
  //setup fire
  fireColors = new int[256];
  fireBuffer = new int[NR_OF_PIXELS+4];

  for (int i = 0; i < 32; ++i) {
    /* black to blue, 32 values*/
    fireColors[i]=color(i<<1, 0, 0);

    /* blue to red, 32 values*/
    fireColors[i + 32]=color(64 - (i << 1), 0, i << 3);

    /*red to yellow, 32 values*/
    fireColors[i + 64]=color(0, i << 3, 255);

    /* yellow to white, 162 */
    fireColors[i + 96]=color(i << 2, 255, 255);
    fireColors[i + 128]=color(64+(i << 2), 255, 255);
    fireColors[i + 160]=color(128+(i << 2), 255, 255);
    fireColors[i + 192]=color(192+i, 255, 255);
    fireColors[i + 224]=color(224+i, 255, 255);
  }

  //---------------------------  
  //setup plasma
  float s1, s2;
  for (int i=0;i<128;i++) {
    s1=sin(i*PI/25);
    s2=sin(i*PI/50+PI/4);
    plasmaPal[i]=color(128+s1*128, 128+s2*128, s1*128);
  }
  cls = new int[NR_OF_PIXELS];

  int y=0;
  for (int x = 0; x < NR_OF_PIXELS; x++) {
    cls[x] = (int)((127.5 + +(127.5 * sin(x / 32.0)))+ (127.5 + +(127.5 * cos(y / 32.0))) + (127.5 + +(127.5 * sin(sqrt((x * x + y * y)) / 32.0)))  ) / 4;
  }
}

//generate buffer
void generator() {

  if (mode==8) {
    updateFireBuffer();
  }


  //for each buffer
  for (int i=0; i<strKali.length(); i++) {
    switch(mode) {
    case 0:
      colorArray[i] = Wheel((frame-i)*2);
      break;

    case 1:
      colorArray[i] = Wheel(frame);
      break;

    case 2:
      if (((frame-i)>>4)%2==1) {
        colorArray[i] = color(0, 0, 0);
      } 
      else {
        colorArray[i] = color(255, 255, 255);
      }
      break;

    case 3:
      if ((frame-i>>1)%2==1) {
        colorArray[i] = color(0, 0, 0);
      } 
      else {
        colorArray[i] = color(255, 255, 255);
      }
      break;

    case 4:
      colorArray[i] = color(255, 255, 255);
      break;

    case 5:      
      int r=int(random(25));
      colorArray[i] = color(255, 255, 255);
      if (i==4 || i==6) {        
        if (r==2) {
          colorArray[i] = color(0, 0, 0);
        }
      }
      break;

    case 6:
      if (beat.isKick()) {
        colorArray[i] = color(255, 255, 255);
      } 
      else {
        colorArray[i] = color(0, 0, 0);
      }
      break;

    case 7:
      int c = int(in.mix.level()*soundSensitive.getValue());
      if (c>255) c=255;
      colorArray[i] = color(c, c, c);
      break;

    case 8:
      colorArray[i] = fireColors[ fireBuffer[i+4] ];
      break;

    case 9:
      colorArray[i] = plasmaPal[frame-(cls[i])&127];
      break;
    }
  }

  //very seldom in hotel mode, make everything black
  int r=int(random(77));
  if (mode == 5 && r==34) {
    for (int i=0; i<strKali.length(); i++) {
      colorArray[i] = color(0, 0, 0);
    }
  }
}


void updateFireBuffer() {
  int rnd = int(random(16));
  /* the lower the value, the intense the fire, compensate a lower value with a higher decay value*/
  if (rnd > 8) {
    fireBuffer[0] = 255;
  } 
  else {
    fireBuffer[0] = 0;
  }

  for (int i=0; i<fireBuffer.length-1; i++) {
    int a = (fireBuffer[i] + fireBuffer[i+1])/2;
    if (a>1) {
      a--;
    }
    fireBuffer[i+1]=a;
  }
}

