double xsteps, ysteps, winsizex, winsizey, xmin, xmax, ymin, ymax;
int maxiter, cmult;
boolean saveFlag = false;

class Complex {
    double real;   // the real part
    double img;   // the imaginary part

    public Complex(double real, double img) {
        this.real = real;
        this.img = img;
    }

    public Complex multi(Complex b) {
        double real = this.real * b.real - this.img * b.img;
        double img = this.real * b.img + this.img * b.real;
        return new Complex(real, img);
    }
    
    public Complex add(Complex b) {
      double real = this.real + b.real;
      double img = this.img + b.img;
      return new Complex(real, img);
    }
    
    public double abs() {
      return Math.sqrt(this.real * this.real + this.img * this.img);
    }
}

int Mandelbrot(Complex c, Complex z, int i) {
  if (z.abs() > 2) return i;  
  if (i < maxiter) {
    return Mandelbrot(c, z.multi(z).add(c), i + 1);
  } else {
    return i;
  }
}


void drawPoint(double x, double y, int z, int min_iters, int max_iters) {
  float cl = ((float)z - min_iters) / (max_iters - min_iters); 
  float r = 0, g = 0, b = 0;
  // r = 1800 * cl;
  // b = (255 / .7 * (cl - .3));
  // g = (255 / .1 * (cl - .9));  
  b = cmult * cl;
  g = cmult / 4 * cl;
  //if (r > 255) r = 0;
  //if (b > 255) b = 0;
  if (cl == 1) {
    r = 0;
    b = 0;
    g = 0;
  }
  if (r < 0) r = 0;
  if (r > 255) r = 255;
  if (b < 0) b = 0;
  if (b > 255) b = 255;
  if (g < 0) g = 0;
  if (g > 255) g = 255;  
  stroke(r, g, b);
  fill(r, g, b);
  ellipse((float)((x - xmin) / (xmax - xmin) * winsizex), (float)((y - ymin) / (ymax - ymin) * winsizey), (float)(winsizex / xsteps), (float)(winsizey / ysteps));
}

void setup() {
  size(400, 400);
  surface.setResizable(true);
  winsizex = 700;
  winsizey = winsizex * .75;
  xsteps = 25 * winsizex / winsizey;
  ysteps = 25;
  surface.setSize((int)winsizex, (int)winsizey);
  background(0);
  xmin = -2;
  xmax = .7;
  ymin = -1.3;
  ymax = 1.3;
  maxiter = 50;
  cmult = 255;
}

void draw() {
  
  xsteps = xsteps * 1.5;
  ysteps = ysteps * 1.5;
  
  if (xsteps >= winsizex) xsteps = winsizex; 
  if (ysteps >= winsizey) ysteps = winsizey;
  if (xsteps + ysteps >= winsizex + winsizey) {
    if (saveFlag) {
      save("screenshot.png");
      saveFlag = false;
    }
    noLoop();
  }
  
  int stackSize = (int)((winsizex + 1) * (winsizey + 1));
  
  double[] points_x = new double[stackSize];
  double[] points_y = new double[stackSize];
  int[] iters = new int[stackSize];

  int i = 0;
  for(double x = xmin; x <= xmax; x += (xmax - xmin) / xsteps) {
    for(double y = ymin; y <= ymax; y += (ymax - ymin) / ysteps) {      
      points_x[i] = x;
      points_y[i] = y;
      int it = Mandelbrot(new Complex(x, y), new Complex(0, 0), 0);
      iters[i] = it;
      i++;
    }
  }
  
  int max_iters = max(iters);
  int min_iters = min(iters);
    
  for(int j = 0; j < i; j++) {
    drawPoint(points_x[j], points_y[j], iters[j], min_iters, max_iters);
  }
}

void reset() {
  xsteps = 25;
  ysteps = 25;
  loop();
}

void zoom(float e) {
  double xrng = (xmax - xmin);
  double yrng = (ymax - ymin);
  if (e == -1.0) {
    //zoom in
    xmin = xmin + xrng * .1;
    xmax = xmax - xrng * .1;
    ymin = ymin + yrng * .1;
    ymax = ymax - yrng * .1;
  } else {
    //zome out
    xmin = xmin - xrng * .1;
    xmax = xmax + xrng * .1;
    ymin = ymin - yrng * .1;
    ymax = ymax + yrng * .1;
  }
  reset();
}

void mouseWheel(MouseEvent event) {
  zoom(event.getCount());
}

void mousePressed() {
  recenter();
}

void recenter() {
  double x = mouseX / winsizex;
  double y = mouseY / winsizey;
  recenter_p(x, y);
}

void recenter_p(double x, double y) {
  double xrng = xmax - xmin;
  double yrng = ymax - ymin;  
  xmin = xmin + xrng * (x - .5);
  xmax = xmax + xrng * (x - .5);
  ymin = ymin + yrng * (y - .5);
  ymax = ymax + yrng * (y - .5);
  reset();  
}

void keyPressed() {
  if (keyCode == 83) {
    saveFlag = true;
    save("screenshot.png");
  }
  if (keyCode == 61) {
    maxiter = maxiter + 10;
    println(maxiter);
    reset();
  }
  if (keyCode == 45) {
    maxiter = maxiter - 10;
    println(maxiter);
    reset();
  }
  if (keyCode == 91) {
    cmult = round(cmult * .9);
    reset();
  }
  if (keyCode == 93) {
    cmult = round(cmult * 1.1);
    reset();
  }
  if (keyCode == 38) {
    recenter_p(.5, .4);
  }
  if (keyCode == 39) {
    recenter_p(.6, .5);
  }
  if (keyCode == 40) {
    recenter_p(.5, .6);
  }
  if (keyCode == 37) {
    recenter_p(.4, .5);
  }
  if (keyCode == 46) {
    //zoom in
    zoom(-1.0);
  }
  if (keyCode == 44) {
    //zome out
    zoom(1.0);
  }
}