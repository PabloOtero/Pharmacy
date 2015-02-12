// version 1.0

class guiElement {
  String name = "";
  float width, height, x0, y0;
  
  boolean update() {return false;}
  
  boolean offerMousePress() {return false;}
  
  float[] position() {
    float[] r = {x0, y0, width, height};
    return r;
  }  
}



class button extends guiElement {
  color neutralColor, activeColor, highlightColor;
  color backgroundColor = color(255);
  // these make a color palette, that can be used in different ways.
  // use foreColor() and bkgndColor() for drawing.
  boolean active = false;
  boolean pressed = false;
  boolean hidden = false;
  int thetextsize = 9;
  float leading = 0.8;
  
  void construct(String name0, float[] pos, color neutral, color actv) {
    neutralColor = neutral;
    activeColor = actv;
    highlightColor = darken(activeColor);
    x0 = pos[0]; y0 = pos[1]; width = pos[2]; height = pos[3];
    name = name0;
  }

  void drawFace() {
    noStroke();
    fill(foreColor());
    rectMode(CORNER);
    rect(x0,y0,width,height);
  }
  
  void drawName() {
    fill(bkgndColor());
    textAlign(CENTER);
    textSize(thetextsize);
    textLeading(leading*thetextsize);
    text(name,x0+width/2,y0+height/2+thetextsize/2);
  }
  
  color foreColor() {
    if (pressed) {
      return(highlightColor);
    } else if (over()) {
      return(activeColor);
    } else {
      return(neutralColor);
    }
  }
  
  color bkgndColor() {
    return backgroundColor;
  }
  
  void draw() {
    if (!hidden) {
      drawFace();
      drawName();
    }
  }
  
  boolean over() {
    return (((mouseX>=x0) && (mouseX<=x0+width)) && ((mouseY>=y0) && (mouseY<=y0+height)));
  }
  
  boolean offerMousePress() {
    pressed = over() && (!hidden);
    return pressed;
  }
  
  boolean update() {
    // returns true when the button is released.
    boolean result = false;
    if (pressed) {
      active = over();
      pressed = mousePressed;
    }
    if (active && (!mousePressed)) {
      pressed = false;
      active = false;
      result = true;
    } 
    draw();
    return result;
  }
  
}


class textButton extends button {

  textButton(String name0, float[] pos, color neutral, color actv) {
    construct(name0, pos, neutral, actv);
    thetextsize = round(height/3);
  }   
}


class polyButton extends button {
  
  float[] px,py; // coords of the polygon
  boolean drawSecondPoly = false;
  float[] px2, py2; // optional second polygon, for more complex shapes
  boolean drawCutoutPoly = false;
  float[] cx,cy; // option extra polygon in bkgndColor() instead of foreColor()
  boolean showName = true;
  
  polyButton(String name0, float[] pos, color neutral, color actv, float[] xx, float[] yy) {
    construct(name0, pos, neutral, actv);
    thetextsize = round(height/3);
    definePoly(xx,yy);
  }   

  void definePoly(float[] xx, float[] yy) {
    px = xx;
    py = yy;
  }
  
  void defineSecondPoly(float[] xx, float[] yy) {
    drawSecondPoly = true;
    px2 = xx;
    py2 = yy;
  }
  
  void defineCutoutPoly(float[] xx, float[] yy, color col) {
    drawCutoutPoly = true;
    cx = xx;
    cy = yy;
  }
  
  void drawFace() {
    fill(foreColor());
    noStroke();
    beginShape(POLYGON);
    for (int i=0; i<px.length; i++) {
      vertex(x0+width*px[i],y0+height*(1-py[i]));
    }
    endShape();
    if (drawSecondPoly) {
      beginShape(POLYGON);
      for (int i=0; i<px2.length; i++) {
        vertex(x0+width*px2[i],y0+height*(1-py2[i]));
      }
    }
    if (drawCutoutPoly) {
      fill(bkgndColor());
      beginShape(POLYGON);
      for (int i=0; i<px2.length; i++) {
        vertex(x0+width*px2[i],y0+height*(1-py2[i]));
      }
    }
  }
  
  void drawName() {
    if (showName) {
      textSize(thetextsize);
      textAlign(CENTER);
      textLeading(leading*thetextsize);
      fill(foreColor());
      text(name, x0+width/2, y0+height+1.2*thetextsize);
    }
  }

}




class multistatePolyButton extends guiElement {
  
  polyButton[] states;
  int lastDefined = -1;
  int current = 0;
  boolean hidden = false;
  
  multistatePolyButton(int N, float[] pos) {
    states = new polyButton[N];
    x0 = pos[0]; y0 = pos[1]; width = pos[2]; height = pos[3];
  }
  
  multistatePolyButton(int N, polyButton firstState) {
    states = new polyButton[N];
    addState(firstState);
    x0 = firstState.x0; y0 = firstState.y0; width = firstState.width; height = firstState.height;
  }
  
  multistatePolyButton(String name0, int N, float[] pos) {
    name = name0;
    states = new polyButton[N];
    x0 = pos[0]; y0 = pos[1]; width = pos[2]; height = pos[3];
  }
  
  multistatePolyButton(String name0, int N, polyButton firstState) {
    name = name0;
    states = new polyButton[N];
    addState(firstState);
    x0 = firstState.x0; y0 = firstState.y0; width = firstState.width; height = firstState.height;
  }

  
  
  int addState(polyButton btn) {
    if (lastDefined < states.length) {
      lastDefined++;
      states[lastDefined] = btn;
      states[lastDefined].hidden = true;
      if (lastDefined==current) {
        syncPosition();
      }
      return lastDefined;
    } else {
      return -1;
    }
  }
  
  polyButton currentState() {
    return states[current];
  }
  
  void syncPosition() {
    polyButton s = currentState();
    x0 = s.x0;
    y0 = s.y0;
    width = s.width;
    height = s.height;
  }
  
  boolean update() {
    boolean result = false;
    if (!hidden) {
      states[current].hidden = false;
      result = states[current].update();
      if (result) {
        states[current].hidden = true;
        current++;
        if (current==states.length) {current=0;}
        syncPosition();
      }
    }
    return result;
  }
  
  void draw() {
    if (!hidden) {
      states[current].draw();
    }
  }
  
  boolean offerMousePress() {
    boolean captured = false;
    if (!hidden) {
      captured = states[current].offerMousePress();
    }
    return captured;
  }
  
}



class slider extends guiElement {
  color neutralColor, activeColor, highlightColor;
  color backgroundColor = color(255);
  // these define a color palette, that can be used in different ways.
  // use foreColor() and bkgndColor() for drawing.
  float indicatorWidth;
  boolean active = false;
  boolean pressed = false;
  boolean hidden = false;
  boolean showName = true;
  boolean showVal = true;
  float nameTextSize, valTextSize;
  float leading = 0.8;
  int decimalPlaces = 2;
  boolean quantized = false;
  float quantizeUnit;
  
  float dataMin, dataMax;
  boolean logScale = false;
  float pos = 0.5; // current position, 0..1
  
  slider(String name0, float[] pos, color neutral, color actv, float minVal, float maxVal) {
    neutralColor = neutral;
    activeColor = actv;
    highlightColor = darken(activeColor);
    x0 = pos[0]; y0 = pos[1]; width = pos[2]; height = pos[3];
    indicatorWidth = height;
    nameTextSize = height;
    valTextSize = 1.2*height;
    name = name0;
    dataMin = minVal;
    dataMax = maxVal;
  }
  
  void quantize(float unit) {
    quantized = true;
    quantizeUnit = unit;
    if (abs(unit-round(unit)) < 1e-6) {
      decimalPlaces = 0;
    }
    setVal(getVal());
  }

  color foreColor() {
    if (pressed) {
      return(highlightColor);
    } else if (over()) {
      return(activeColor);
    } else {
      return(neutralColor);
    }
  }
  
  color bkgndColor() {
    return backgroundColor;
  }
  
  void drawBar() {
    rectMode(CORNER);
    noStroke();
    fill(bkgndColor());
    rect(x0,y0,width,height);
    fill(foreColor());
    float x1 = x0 + (width-indicatorWidth)*getPos();
    rect(x1,y0,indicatorWidth,height);
  }
  
  void drawName() {
    fill(foreColor());
    textAlign(RIGHT);
    textSize(nameTextSize);
    textLeading(leading*nameTextSize);
    text(name+" ",x0,y0+height);
  }
  
  void drawVal() {
    fill(foreColor());
    textAlign(LEFT);
    //textSize(valTextSize);
    textSize(14);
    textLeading(leading*valTextSize);
    text(" "+val2string(getVal()), x0+width, y0+height);  //POT
    //text(" "+val2string(time_day[count]), x0+width, y0+height);
    //text(" "+time_day[count]+"/"+time_month[count]+"/"+time_year[count],  x0+width/5, y0+height+15);
    //text(" "+time_day[count]+" "+months[time_month[count]-1]+" "+time_year[count],  x0+width/6, y0+height+15);
  }
  
  void draw() {
    if (!hidden) {
      drawBar();
      if (showName) {drawName();}
      if (showVal) {drawVal();}
    }
  }
  
  boolean over() {
    return (((mouseX>=x0) && (mouseX<=x0+width)) && ((mouseY>=y0) && (mouseY<=y0+height)));
  }
  
  boolean offerMousePress() {
    pressed = over() && (!hidden);
    return pressed;
  }
  
  boolean update() {
    // returns true if the user is changing the position of the slider.
    boolean result = false;
    if (!hidden) {
      pressed = pressed && mousePressed;
      active = over() && pressed;
      if (active) {
        float newpos = (mouseX - x0) / (width - indicatorWidth);
        if (newpos != getPos()) {
          setPos(newpos);
          result = true;
        }
      }
      draw();
    }
    return result;
  }
  
  // use these four routines for reading & changing the position of the slider.
  // pos = relative position, 0..1
  // val = value in data units  
  float getPos() {return pos;}
  float getVal() {return pos2val(getPos());}
  void setPos(float p) {pos = constrain(p, 0, 1);}
  void setVal(float v) {setPos(val2pos(v));}

  // these are general conversion functions, that can be used for values other than the current one
  // e.g., to find out the current min and max values allowed, use pos2val(0) and pos2val(1)
  String val2string(float v) {
    if (decimalPlaces==0) {
      return str(round(v));
    } else {
      float p = pow(10,decimalPlaces);
      return str(round(v*p)/(float)p);
    }
  }
  
  float val2pos(float v) {
    float p;
    if (quantized) {
      v = round(v/quantizeUnit)*quantizeUnit;
    }
    if (logScale) {
      p = (log(v)-log(dataMin))/(log(dataMax)-log(dataMin));
    } else {
      p = (v-dataMin)/(dataMax-dataMin);
    }
    return p;
  }
  
  float pos2val(float p) {
    float v;
    if (logScale) {
      v = dataMin * pow(dataMax/dataMin, p);
    } else {
      v = dataMin + (dataMax-dataMin) * p;
    }
    if (quantized) {
      v = round(v/quantizeUnit)*quantizeUnit;
    }
    return v;
  }  
  
}





class toolbar extends guiElement {
  guiElement[] elements;
  float spacing;
  int length=0; // number of defined elements
  float unoccupiedX0, unoccupiedWidth;
  boolean hidden = false;
  slider lastSliderAdded; // this is a kluge to make the "below" option work: elements[length-1].x0 returns 0 when elements[length-1] is a slider
  guiElement lastUpdated = null;
  
  toolbar(float[] pos, int maxElements) {
    elements = new guiElement[maxElements];
    x0 = pos[0]; y0 = pos[1]; width = pos[2]; height = pos[3];
    spacing = height/2;
    unoccupiedX0 = x0;
    unoccupiedWidth = width;
  }
  
  guiElement lastAdded() {
    return elements[length-1];
  }
  
  guiElement find(String nm) {
    guiElement theOne = null;
    boolean found = false;
    for (int i=0; ((i<length) && (!found)); i++) {
      found = nm.equals(elements[i].name);
      if (found) theOne = elements[i];
    }
    return theOne;
  }
  
  guiElement addElement(guiElement E) {
    if (length < elements.length) {
      length++;
      elements[length-1] = E;
      return E;
    } else {
      return null;
    }    
  }
  
  // to add an element to the toolbar, use one of the following: arguments match the constructors for
  // each class, but replace the position rectangle with "left" or "right."
  textButton addTextButton(String name0, String alignmt, color neutral, color actv) {
    return (textButton) addElement(new textButton(name0, nextPosition(alignmt,height), neutral, actv));
  }
  
  polyButton addPolyButton(String name0, String alignmt, color neutral, color actv, float[] xx, float[] yy) {
    return (polyButton) addElement(new polyButton(name0, nextPosition(alignmt,height), neutral, actv, xx, yy));
  }

  multistatePolyButton addMultistatePolyButton(String name0, int N, String alignmt) {
    return (multistatePolyButton) addElement(new multistatePolyButton(name0, N, nextPosition(alignmt,2.5*height)));
  }

  slider addSlider(String name0, String alignmt, color neutral, color actv, float minVal, float maxVal) {
    float ht = height/3;
    float wd = 10*ht;
    float[] pos = nextPosition(alignmt,wd);
    pos[1] += (pos[3]-ht)/2;
    pos[3] = ht;
    slider S = new slider(name0, pos, neutral, actv, minVal, maxVal);
    addElement(S);
    lastSliderAdded = S;
    textSize(S.nameTextSize);
    float nameWidth = textWidth(S.name+" ");
    float valWidth = max(textWidth(S.val2string(S.pos2val(0))+" "), textWidth(S.val2string(S.pos2val(1))+" "));
    if (alignmt.equals("left") || alignmt.equals("LEFT")) {
      S.x0 += nameWidth;
      unoccupiedX0 += (nameWidth + valWidth);
      unoccupiedWidth -= (nameWidth + valWidth);
    } else if (alignmt.equals("right") || alignmt.equals("RIGHT")) {
      S.x0 -= valWidth;
      unoccupiedWidth -= (nameWidth + valWidth);
    } 
    return S;
  }
  
  float[] unoccupied() {
    float[] r = {unoccupiedX0, y0, unoccupiedWidth, height};
    return r;
  }

  float[] nextPosition(String alignmt, float dx) {  
    float dxtot = dx;
    float[] r;
    if (alignmt.equals("left") || alignmt.equals("LEFT")) { // in the main toolbar, aligned left
      if (unoccupiedX0 > x0) {dxtot += spacing;} // add spacer unless all the way at the left
      unoccupiedX0 += dxtot;
      unoccupiedWidth -= dxtot;
      r = defineRect(unoccupiedX0 - dx, y0, dx, height);
    } else if (alignmt.equals("right") || alignmt.equals("RIGHT")) { // in the main toolbar, aligned right
      if (unoccupiedX0+unoccupiedWidth < x0+width) {dxtot += spacing;} // add spacer unless all the way at the right
      unoccupiedWidth -= dxtot;
      r = defineRect(unoccupiedX0 + unoccupiedWidth, y0, dx, height);
    } else if (alignmt.equals("below") || alignmt.equals("BELOW")) { // directly below the last element defined
      // note: when the last element is a slider, the line below returns 0
      float xx = elements[length-1].x0;
      float yy = elements[length-1].y0 + elements[length-1].height + spacing;
      if (elements[length-1] instanceof slider) {
        xx = lastSliderAdded.x0;
        yy = lastSliderAdded.y0+1.5*lastSliderAdded.height;
      }
      r = defineRect(xx, yy, dx, height);
    } else {
      r = defineRect(0,0,0,0);
    }
    return r;
  }
    
  boolean update() {
    boolean result = false;
    if (!hidden) {
      for (int i=0; i<length; i++) {
        boolean updated = elements[i].update();
        if (updated) {
          lastUpdated = elements[i];
          result = true;
        }
      }
    }
    return result;
  }
  
  boolean offerMousePress() {
    boolean captured = false;
    for (int i=length-1; ((i>=0) && (!captured)); i=i-1) {
      captured = elements[i].offerMousePress();
    }
    return captured;
  } 
 
}



class dragSelector {
  float awareWidth, awareHeight, awareX0, awareY0; // the screen region that's monitored and selectable
  float selectedWidth, selectedHeight, selectedX0, selectedY0; // the current size of the selected rectangle; when not pressed, stores the last rect selected
  boolean pressed = false;
  boolean aware = true;
  
  dragSelector(float[] pos) {
    setAwareRect(pos);
    selectedX0 = -1; selectedY0 = -1; selectedWidth = -1; selectedHeight = -1;
  }
  
  void setAwareRect(float[] pos) {
    awareX0 = pos[0]; awareY0 = pos[1]; awareWidth = pos[2]; awareHeight = pos[3];
  }

  void draw() {
    fill(color(255,255,255,0.2*255));
    stroke(color(255,255,255));
    rectMode(CORNER);
    rect(selectedX0,selectedY0,selectedWidth,selectedHeight); 
  }
  
  boolean over() {
    return (((mouseX>=awareX0) && (mouseX<=awareX0+awareWidth)) && ((mouseY>=awareY0) && (mouseY<=awareY0+awareHeight)));
  }
  
  boolean offerMousePress() {
    pressed = false;
    if (aware) {
      pressed = over();
      if (pressed) {
        selectedX0 = mouseX;
        selectedY0 = mouseY;
        selectedWidth = 0;
        selectedHeight = 0;
      }
    }
    return pressed;
  }
  
  boolean update() {
    boolean released = false;
    if (aware) {
      pressed = (pressed) && (mousePressed); // already activated and mouse still down?
      if (pressed) {
        float x1 = constrain(mouseX, awareX0, awareX0+awareWidth);
        selectedWidth = x1 - selectedX0;   
        float y1 = constrain(mouseY, awareY0, awareY0+awareHeight);  
        selectedHeight = y1 - selectedY0;
        draw();
      } else {
        released = true;
      }
    }
    return released;
  }
  
  float[] selection() {
    float[] r = {selectedX0, selectedY0, selectedWidth, selectedHeight};
    return r;
  }
  
}

