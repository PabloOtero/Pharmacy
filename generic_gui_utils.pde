// version 1.0

// color utilities ---------------------------------------

color colorblend(color c1, color c2, float r) {
  return color(lerp(red(c1),red(c2),r),lerp(green(c1),green(c2),r),lerp(blue(c1),blue(c2),r),lerp(alpha(c1),alpha(c2),r));
}

color shift(color col, float r) {
  if (r>0) {
    return colorblend(col,color(255,255,255,alpha(col)),r);
  } else {
    return colorblend(col,color(0,0,0,alpha(col)),-r);  
  }
}

color lighten(color col) {return shift(col,0.25);}

color darken(color col) {return shift(col,-0.25);}

color randomshift(color col) {
  return shift(col, random(-0.5,0.5));
}

color colorinterp(float val, float lowval, float highval, color[] cmap) {return colorinterp(val,lowval,highval,cmap,"nearest");}
color colorinterp(float val, float lowval, float highval, color[] cmap, String mode) {
  if (mode.equals("linear")) {
    float level = constrain((val-lowval)/(highval-lowval),0,1-1e-6) * cmap.length;
    int level0 = floor(level);
    int level1 = constrain(ceil(level),0,cmap.length-1);
    return colorblend(cmap[level0],cmap[level1],level-level0);
  } else {
    int level = floor(constrain((val-lowval)/(highval-lowval),0,1-1e-6) * cmap.length);
    return cmap[level];
  }
}

color[] warmrainbow() {return warmrainbow(20);}
color[] warmrainbow(int n) {return warmrainbow(n, 0.9, 0.3);}
color[] warmrainbow(int n, float bright, float contrast) {
  // nice colorscale from blue to yellow to red
  float Hblue = 0.55; // hues for end & middle colors
  float Hyellow = 0.16667;
  float Hred = 0;
  float dipWidth = 1.5; // width of the dip in saturation over green
  
  float[] H = new float[n];
  float[] S = new float[n];
  float[] B = new float[n];
  int N = n-1;
  int iy = floor(n/(float)2); // index of yellow, the middle color
  
  // hue
  for (int i=0; i<=iy; i++) {
    H[i] = Hblue - (Hblue-Hyellow) *sq(i/(float)iy);
  }
  for (int i=iy+1; i<n; i++) {
    H[i] = lerp(H[iy],Hred,(i-iy)/((float)n-iy));
  }
  
  //saturation
  // find greenest color
  int ig = 0;
  for (int i=1; i<n; i++) {
    if (abs(H[i]-0.3333) < abs(H[ig]-0.3333)) {ig = i;}
  }
  // gaussian dip in saturation
  for (int i=0; i<n; i++) {
    S[i] = 1 - 0.5*exp(-dipWidth*sq(i/(float)ig-1));
  }
  
  // brightness
  float b = 4*contrast/N;
  float a = -b/N;
  for (int i=0; i<iy; i++) {
    B[i] = bright - lerp(contrast,0,i/((float)iy-1));
  }
  for (int i=iy; i<n; i++) {
    B[i] = a*sq(i) + b*i + bright - contrast;
  }
  
  colorMode(HSB);
  color[] map = new color[n];
  for (int i=0; i<map.length; i++) {
    map[i] = color(H[i]*255,S[i]*255,B[i]*255);
  }
  colorMode(RGB);
  
  return map;
}


// other utilities ---------------------------------------

float[] defineRect(float x0, float y0, float wd, float ht) {
  float[] r = {x0,y0,wd,ht};
  return r;
}

