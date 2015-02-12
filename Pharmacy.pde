/* @pjs crisp="true"; pauseOnBlur="true"; */

//
//  This Processing software attempts to visualize data taken during
//  2012 in the Emergency Department of the Meixoeiro Hospital, Vigo, Spain.
//  
//  A very simple linear model based on real information is used to interpolate data during
//  dates without records. Moreover, some parameters are included to analyze potential
//  hospital savings done by the intervention of a pharmacist.
//
//  Pablo Otero, April 2013. Revised October 2014.


PFont f;

toolbar tools;
ADRadio radioButton, radioButton2;


float t=0;
int bkgndColor = 0;
float x;
float a1 = 10;
//int count;
color c1, c2;
color colorfondo = color(68,169,188);
color colorrelease = color(175,37,81);

String[] options = {"Euro","Dollar"};
String[] options2 = {"None","Mondays","Colder days","Warmer days","Strong thermal oscillation"};
String[] months = {"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"};

String[] lines;
String[] parameters;	

float k;
float[] y1;
 
// Initiate with only one element
float[] time = new float[1];
int[] time_year = new int[1];
int[] time_month = new int[1];
int[] time_day = new int[1]; 
int[] patients = new int[1];
int[] intpatients = new int[1];
float[] cold = new float[1];
float[] hcold = new float[1];
float[] warm = new float[1];
int[] dayoftheweek = new int[1];

//Specific parameters
int yfactor=2;
int totalpatients = 0;
float meanpatients;
//float effort;
int acceptance;
float lethal;
float serious;
float significant;
float nonsignificant;
float lethal_old;
float serious_old;
float significant_old;
float nonsignificant_old;
boolean inicio = true;
float kk1, kk2, kk3, resto;
float reparto, resto1, resto2, resto3;
boolean botonsoltado = false; 
int jold=0;
float euro;
float admission;
boolean pausado = false;

int int_days = 0;
int total_intpatients = 0;

int min_intpatients = 10000;
int max_intpatients = 0;

// Data in parameters.txt 
float costperday;
float mean_days;
float risk_lethal;         
float risk_serious;         
float risk_significant;     
float risk_nonsignificant;  
float meanacceptance;
float meanadmission;
float currencyfactor;
float minT;
float maxT;
float diffT;

float annualpatients;    // Extrapolation of the total annual of patients with PRM in the study

import date.js;
      
void setup() {
  
  size(600,600);
  
  y1 = new float[width];

  //Load fonts  
  f = createFont("Arial-Black", 16);

  
  //Load the parameters file
  parameters = loadStrings("parameters.txt"); 
  for (int index = 0; index < parameters.length; index = index + 1) { 
       String[] data = split(parameters[index], '\t');
       if(index==0) {
         costperday=float(data[1]);     
       } else if (index==1) {
         mean_days=float(data[1]);     
       } else if(index==2) {
         risk_lethal=float(data[1]);
       } else if(index==3) {
         risk_serious=float(data[1]);
       } else if(index==4) {
         risk_significant=float(data[1]);
       } else if(index==5) {
         risk_nonsignificant=float(data[1]);
       } else if(index==6) {
         meanacceptance=float(data[1]);
       } else if(index==7) {
         meanadmission=float(data[1]);
       } else if(index==8) {
         currencyfactor=float(data[1]);
       } else if(index==9) {
         minT=float(data[1]);
       } else if(index==10) {
         maxT=float(data[1]);
       } else if(index==11) {
         diffT=float(data[1]);
       }
  }

  
    
  //Load the data file
  lines = loadStrings("data.txt"); 
              
  //Fill variable with data
  // He restado 1 a todo en index
  for (int index = 1; index < lines.length; index = index + 1) { 
       String[] data = split(lines[index], '\t');

       time[index]=Date.parseExact(data[0], "d/M/yyyy");
       //time = (float[]) append(time,Date.parseExact(data[0], "d/M/yyyy"));  
       
       time_day[index-1] = int(time[index].getDate());
       time_month[index-1] = int(time[index].getMonth()+1);
       time_year[index-1] = int(time[index].getFullYear());
       dayoftheweek[index-1] = int(time[index].getDay())+1;
     
       if(int(data[1]) != -9999) {
         patients[index-1] = int(data[1]);
       } else {
         patients[index-1] = patients[index-2];
       }    
       totalpatients = totalpatients + patients[index-1];
       
       intpatients[index-1] = int(data[2]);
       
       if(intpatients[index-1]!=-9999) {
         if(intpatients[index-1] < min_intpatients) {
           min_intpatients = intpatients[index-1];
         }
         if(intpatients[index-1] > max_intpatients) {
           max_intpatients = intpatients[index-1];
         }
       }
       
       if(int(data[2]) != -9999) {
         int_days=int_days+1;
         total_intpatients=total_intpatients+intpatients[index-1];
       }    
           
       //meanT[index] = float(data[3]);
       cold[index-1] = float(data[4]);
       warm[index-1] = float(data[5]);
       hcold[index-1] = float(data[6]);
       
  }
  
  meanpatients=totalpatients/lines.length; // Daily mean patients in the Emergency Unit  
  //annualpatients = total_intpatients*lines.length/int_days; // Extrapolation of the interventions to the study period  
  annualpatients = total_intpatients*365/int_days; // Extrapolation of the interventions to the study period  
  
  yfactor=(max(patients)-meanpatients)*2/90;
  
  //Set up GUI controls
  // the second position is zero in case of pharmacist effort
  float[] pos = {
    width-220, 40, width-20, 40
  };
  color gray1 = #2E4F55;
  color gray2 = darken(gray1);
  color gray3 = darken(gray2);
  
 
  tools = new toolbar(pos, 10);
  tools.addSlider("Speed", "left", gray2, gray3, 0, 1);
  ((slider) tools.lastAdded()).setVal(0.05);
  //tools.addSlider("Pharmacist effort (hours)", "below", gray2, gray3, 0, 4);
  //((slider) tools.lastAdded()).setVal(2);
  tools.addSlider("% Acceptance", "below", gray2, gray3, 0, 100);
  ((slider) tools.lastAdded()).setVal(84);
  tools.addSlider("% Admission", "below", gray2, gray3, 0, 50);
  ((slider) tools.lastAdded()).setVal(27);
  tools.addSlider("% Lethal ", "below", gray2, gray3, 0, 10);
  ((slider) tools.lastAdded()).setVal(0);
  tools.addSlider("% Serious", "below", gray2, gray3, 0, 100);
  ((slider) tools.lastAdded()).setVal(3);
  tools.addSlider("% Significant", "below", gray2, gray3, 0, 100);
  ((slider) tools.lastAdded()).setVal(64);
  tools.addSlider("% Non Significant", "below", gray2, gray3, 0, 100);
  ((slider) tools.lastAdded()).setVal(33);
  
  //Add radio button currency
  radioButton = new ADRadio(width-57, height-90, options, "radioButton");
  radioButton.setDebugOn();
  radioButton.setBoxFillColor(#FFFFFF); 
  radioButton.setValue(0);
  
  //Add radio button external factors
  radioButton2 = new ADRadio(50, 150, options2, "radioButton");
  radioButton2.setDebugOn();
  radioButton2.setBoxFillColor(#FFFFFF); 
  radioButton2.setValue(0); 
}

void draw() {
  
  //smooth();
  background(colorfondo);
  fill(255);
  stroke(255); rect(0,300,width,height);
  stroke(0);
  textFont(f,16);
  tools.update();
  radioButton.update();
  radioButton2.update();
  
   
  a1 = ((slider) tools.find("Speed")).getVal();
  //effort = ((slider) tools.find("Pharmacist effort (hours)")).getVal();
  acceptance = int(((slider) tools.find("% Acceptance")).getVal());
  admission = int(((slider) tools.find("% Admission")).getVal());
  lethal = ((slider) tools.find("% Lethal ")).getVal();
  serious = int( ((slider) tools.find("% Serious")).getVal() );
  significant = int( ((slider) tools.find("% Significant")).getVal() );
  nonsignificant = int( ((slider) tools.find("% Non Significant")).getVal() );
    
  if(inicio) {
     lethal_old = lethal;
     serious_old = serious;
     significant_old = significant;
     nonsignificant_old = nonsignificant;
     inicio = false;
  }  
   
  // Test that different MRP types do not exceed 100%
  MRP_evaluation();
  
 // What currency?
 if(radioButton.getValue() == 0) {
   euro=1;
 } else if (radioButton.getValue() == 1) {
   euro=currencyfactor;
 }        
 
// // Explore data looking for the exact selected time
// for (int index = 0; index < lines.length; index = index + 1) {
//   if(time[index]-a1 >= 0) {
//     count = index;
//     break;
//   }
// }


 
 /////////////////////////
 // Plot patients anomaly
 ////////////////////////
 float tic2 = millis()%2000;
 tic2 = tic2/2000;
 for (int i = 0; i < width; i++) {  
 
     strokeWeight(0.5);   
     int j = (int)(floor(i*(patients.length)/width));
      
          
     y1[i]=patients[j]-meanpatients;  
     
     if(y1[i]>=0) {
      stroke(255,0,0);
     } else{
      stroke(30,0,255); 
     }    
     if(radioButton2.getValue() == 1) {
       if(dayoftheweek[j]==2) {
         stroke(round(tic2*225),round(tic2*225),round(tic2*117)); 
         strokeWeight(2);
       }  
     } else if (radioButton2.getValue() == 2) {
        if(cold[j]<=minT) {
         stroke(round(tic2*225),round(tic2*225),round(tic2*117)); 
         strokeWeight(2); 
       } 
     } else if (radioButton2.getValue() == 3) {
        if(warm[j]>=maxT) {
         stroke(round(tic2*225),round(tic2*225),round(tic2*117)); 
         strokeWeight(2); 
       }    
     } else if (radioButton2.getValue() == 4) {
        if(abs(warm[j]-cold[j])>=diffT) {
         stroke(round(tic2*225),round(tic2*225),round(tic2*117)); 
         strokeWeight(2); 
       } 
     } 
     line(i,350,i,350-y1[i]/yfactor);
     //line(i-lines.length+365,350,i-lines.length+365,350-y1[i]/yfactor);
  }
 
 
 //The default framerate is 60 times per second. Dividing by 60, the displacement of the wave signal is represented in seconds
  if(t>width-ceil(width/(patients.length))) {
   t=0;
  } else {  
   if(pausado==false) {
     t = t + 1*a1;
   }  
  } 
  int t2 = round(t);
  int j = (int)(floor(t2*(patients.length)/width));
  //int j = (int)(round(t2*patients.length/width));

  fill(colorfondo); stroke(255);
  ellipse(t2,350-(patients[j]-meanpatients)/yfactor,10,10);    
  textFont(f,12);
  fill(0);
  text(patients[j],t2,350-(patients[j]-meanpatients)/yfactor-10); 
  String dia =  str(time_day[j]) + months[time_month[j]-1];
  text(dia,t,375);
  
  textFont(f,9); fill(54,54,54);
  //String textito[] = str("Patients in the Emergency Unit (Mean = ") + int(meanpattients) + str(")");
  //text("Patients in the Emergency Unit (Mean = 165)",300,320);
  text(str("Patients in the Emergency Unit (Mean = ") + str(int(floor(meanpatients))) + str(")"),300,320);
  textFont(f,12);
 
  
  //////////////////////
  // Compute saved costs
  //////////////////////
  if(intpatients[j] == -9999) {
    intpatients[j] = round( random(min_intpatients,max_intpatients) );
    //intpatients[j] = round( random(5,30) );
  }  
  if(j!=jold) {
    /* IN CASE OF PHARMACIST EFFORT
    if(effort<=1) {
     intpatients[j] = 0;
    } else if (effort>1 && effort<=2) {
        intpatients[j] = intpatients[j];
    } else if (effort>2 && effort<=3) {
        intpatients[j] = (int)(intpatients[j] + random(0,15) * (effort-2) ); 
    } else if (effort>3 && effort<=4) {
        intpatients[j] = (int)(intpatients[j] + random(0,15) + random(0,15) * (effort-3) );
    }
    */
   jold=j;    
  }   
    
 int treated = (int)(intpatients[j]*acceptance/meanacceptance);
  float treated_lethal = round(treated*lethal/100);
   float treated_serious = round(treated*serious/100);
    float treated_significant = round(treated*significant/100);
     float treated_nonsignificant = round(treated*nonsignificant/100);
 treated = (int)(treated_lethal + treated_serious + treated_significant + treated_nonsignificant);     
   
 int intreated = (int)(round(treated*admission/100));
 float intreated_lethal = round(treated_lethal*admission/100);
   float intreated_serious = round(treated_serious*admission/100);
    float intreated_significant = round(treated_significant*admission/100);
     float intreated_nonsignificant = round(treated_nonsignificant*admission/100);  
  intreated = (int)(intreated_lethal + intreated_serious + intreated_significant + intreated_nonsignificant);   
         
  float saved_lethal=intreated_lethal*mean_days*risk_lethal*costperday*euro*admission/meanadmission/100;
   float saved_serious=intreated_serious*mean_days*risk_serious*costperday*euro*admission/meanadmission/100;
    float saved_significant=intreated_significant*mean_days*risk_significant*costperday*euro*admission/meanadmission/100;
     float saved_nonsignificant=intreated_nonsignificant*mean_days*risk_nonsignificant*costperday*euro*admission/meanadmission/100;
   
  int savedcost= (int)(saved_lethal+saved_serious+saved_significant+saved_nonsignificant);
  float radius_total = sqrt(savedcost/PI); 
  float radius_lethal = sqrt(saved_lethal/PI);
  float radius_serious = sqrt(saved_serious/PI);
  float radius_significant = sqrt(saved_significant/PI);
  float radius_nonsignificant = sqrt(saved_nonsignificant/PI);

// //Draw and arrow
//  pushMatrix();
//  stroke(0);
//  translate(t, 380);
//  float angle = atan((t-115)/(height-192-380));
//  rotate(angle+PI/2);
//  float len = sqrt(abs(t-115)*abs(t-115)+abs(height-192-380)*abs(height-192-380));
//  strokeWeight(1+treated*10/60);
//  line(0,0,len, 0);
//  line(len, 0, len - 4, -4);
//  line(len, 0, len - 4, 4);  
//  popMatrix();
//  strokeWeight(1);  // Default
  
  stroke(255);
  fill(255,0,0);
  //arc(360,height-105,radius_total,radius_total,0,saved_lethal/savedcost*PI*2, PIE);
  arc(360,height-105,radius_total,radius_total,0,saved_lethal/savedcost*PI*2);
  fill(245,119,0);
  //arc(360,height-105,radius_total,radius_total,saved_lethal/savedcost*PI*2,(saved_lethal+saved_serious)/savedcost*PI*2, PIE);
  arc(360,height-105,radius_total,radius_total,saved_lethal/savedcost*PI*2,(saved_lethal+saved_serious)/savedcost*PI*2);
  fill(166,175,39);
  //arc(360,height-105,radius_total,radius_total,(saved_lethal+saved_serious)/savedcost*PI*2,(saved_lethal+saved_serious+saved_significant)/savedcost*PI*2, PIE);
  arc(360,height-105,radius_total,radius_total,(saved_lethal+saved_serious)/savedcost*PI*2,(saved_lethal+saved_serious+saved_significant)/savedcost*PI*2);

 
  ////////////////////////////////////////////////////////////////
  /// Plot one square per treated patients in the Observation Unit 
  ////////////////////////////////////////////////////////////////
  stroke(0);
  fill(255,0,0);
  int contador=0;
  for(int i = 0; i < treated_lethal; i++) {
    if(contador<10) {
      rect(60+10*(contador)+1, height-150, 10, 10, 3);  
    } else {
      rect(60+10*(contador%10)+1, height-150+(contador/10)*10, 10, 10, 3);
    }  
    contador++;
  } 
  fill(245,119,0); 
    for(int i = 0; i < treated_serious; i++) {
    if(contador<10) {
      rect(60+10*(contador)+1, height-150, 10, 10, 3);  
    } else {
      rect(60+10*(contador%10)+1, height-150+( (int)(contador/10) )*10, 10, 10, 3);
    }  
    contador++;
  }  
  fill(166,175,39);
    for(int i = 0; i < treated_significant; i++) {
    if(contador<10) {
      rect(60+10*(contador)+1, height-150, 10, 10, 3);  
    } else {
      rect(60+10*(contador%10)+1, height-150+( (int)(contador/10) )*10, 10, 10, 3);
    }  
    contador++;
  }
  fill(255,255,255);
    for(int i = 0; i < treated_nonsignificant; i++) {
    if(contador<10) {
      rect(60+10*(contador)+1, height-150, 10, 10, 3);  
    } else {
      rect(60+10*(contador%10)+1, height-150+( (int)(contador/10) )*10, 10, 10, 3);
    }  
    contador++;
  }
   
  stroke(128,128,128); 
  noFill(); rect(30, height-180, 170, 140, 10);  
  fill(255); rect(50, height-210, 130, 40, 7); fill(0); text("Patients with MRP",55,height-210+15); text(" Observation Unit",55,height-190+15);
  textFont(f,10);
  fill(255,0,0); rect(40, height-30, 10, 10, 3); fill(0); text("Lethal",40+10+5,height-20);
  fill(245,119,0); rect(140, height-30, 10, 10, 3); fill(0); text("Serious",140+10+5,height-20);
  fill(166,175,39); rect(40, height-15, 10, 10, 3); fill(0); text("Significant",40+10+5,height-5);
  fill(255,255,255); rect(140, height-15, 10, 10, 3); fill(0); text("Non significant",140+10+5,height-5);
  textFont(f,12);
  fill(255); ellipse(30,height-60,30,30); fill(0); text(treated,23,height-55);
  
  line(204,height-100,204,height-110); line(204,height-100,210,height-100); line(204,height-110,210,height-110);
  line(210,height-110,210,height-114); line(210,height-100,210,height-96);
  line(210,height-114,217,height-105); line(210,height-96,217,height-105);
  
  ////////////////////////////////////////////
  /// Plot one square per hospitalized patient
  ////////////////////////////////////////////
  stroke(0);
  fill(255,0,0);
  contador=0;
  int desfasex = 190;
  for(int i = 0; i < intreated_lethal; i++) {
    if(contador<4) {
      rect(40+desfasex+10*(contador)+1, height-150, 10, 10, 3);  
    } else {
      rect(40+desfasex+10*(contador%4)+1, height-150+( (int)(contador/4) )*10, 10, 10, 3);
    }  
    contador++;
  }  
  fill(245,119,0); 
    for(int i = 0; i < intreated_serious; i++) {
    if(contador<4) {
      rect(40+desfasex+10*(contador)+1, height-150, 10, 10, 3);  
    } else {
      rect(40+desfasex+10*(contador%4)+1, height-150+( (int)(contador/4) )*10, 10, 10, 3);
    }  
    contador++;
  }  
  fill(166,175,39);
    for(int i = 0; i < intreated_significant; i++) {
    if(contador<4) {
      rect(40+desfasex+10*(contador)+1, height-150, 10, 10, 3);  
    } else {
      rect(40+desfasex+10*(contador%4)+1, height-150+( (int)(contador/4) )*10, 10, 10, 3);
    }  
    contador++;
  }
  fill(255,255,255);
    for(int i = 0; i < intreated_nonsignificant; i++) {
    if(contador<4) {
      rect(40+desfasex+10*(contador)+1, height-150, 10, 10, 3);  
    } else {
      rect(40+desfasex+10*(contador%4)+1, height-150+( (int)(contador/4) )*10, 10, 10, 3);
    }  
    contador++;
  }
  
  stroke(128,128,128);  
  noFill(); rect(30+desfasex, height-180, 60, 140, 10);  
  fill(255); rect(15+desfasex, height-190, 90, 20, 7); fill(0); text("Admissions",25+desfasex,height-190+15);
  textFont(f,12);
  fill(255); ellipse(30+desfasex,height-60,30,30); fill(0); text(intreated,23+desfasex,height-55);
  
  desfasex=80;
  line(204+desfasex,height-100,204+desfasex,height-110); line(204+desfasex,height-100,210+desfasex,height-100); line(204+desfasex,height-110,210+desfasex,height-110);
  line(210+desfasex,height-110,210+desfasex,height-114); line(210+desfasex,height-100,210+desfasex,height-96);
  line(210+desfasex,height-114,217+desfasex,height-105); line(210+desfasex,height-96,217+desfasex,height-105);
  
  
  textFont(f,10);
  text("Savings per day",320,height-180);
  
  fill(0,0,0);
  if(savedcost>0){
   if(euro==1) { 
     text(savedcost + " EUR",340,width-50);
   } else {
     text(savedcost + " $",340,width-50);
   }  
  }
  if(savedcost==0){
   if(euro==1) { 
     text("0 EUR",340,height-30);
   } else {
     text("0 $",340,height-30);
   }  
  } 
  
 //Finally, compute an estimation of the annual savings
 treated = (int)(annualpatients*acceptance/meanacceptance*admission/100);
  treated_lethal = round(treated*lethal/100);
   treated_serious = round(treated*serious/100);
    treated_significant = round(treated*significant/100);
     treated_nonsignificant = round(treated*nonsignificant/100);
 treated = (int)(treated_lethal + treated_serious +  treated_significant + treated_nonsignificant); 
  saved_lethal=treated_lethal*mean_days*risk_lethal*costperday*euro/100;
   saved_serious=treated_serious*mean_days*risk_serious*costperday*euro/100;
    saved_significant=treated_significant*mean_days*risk_significant*costperday*euro/100;
     saved_nonsignificant=treated_nonsignificant*mean_days*risk_nonsignificant*costperday*euro/100; 
  savedcost= (int)(saved_lethal+saved_serious+saved_significant+saved_nonsignificant);
  
  fill(0,0,0);
  textFont(f,10);
  text("Total savings",width-140,height-25);
  textFont(f,14);
  if(savedcost>0){
   if(euro==1) { 
     text(savedcost + " EUR",width-135,height-40);
   } else {
     text(savedcost + " $",width-135,height-40);
   }  
  }
  if(savedcost==0){
   if(euro==1) { 
     text("0 EUR",width-135,height-40);
   } else {
     text("0 $",width-135,height-40);
   }  
  }  
  fill(colorfondo);
  //rect(width-130,height-55,60,-100*savedcost/1000000,10,10,0,0);
  rect(width-130,height-65,60,-100*savedcost/1000000);
  
  //Boton pause
  if(pausado==false) {
    stroke(128); fill(255);
    ellipse(270,270,28,28);
    stroke(colorfondo); strokeWeight(4); strokeCap(PROJECT);
    line(270-4,270-4,270-4,270+4);
    line(270+4,270-4,270+4,270+4);
    textFont(f,8);
    text("Pause",258,292);
    strokeWeight(1);
    if(mouseX>(270-24) && mouseX<(270+24) && mouseY>(270-24) && mouseY<(270+24) ) {
      stroke(128); fill(128);
      ellipse(270,270,28,28);
      stroke(255); strokeWeight(4); strokeCap(PROJECT);
      line(270-4,270-4,270-4,270+4);
      line(270+4,270-4,270+4,270+4);
      if(mousePressed==true) {
        if(pausado==true) {
          pausado=false;
        } else {
          pausado=true;
        }
      }  
    } 
    strokeWeight(1); 
  } else {
    stroke(128); fill(255);
    ellipse(270,270,28,28);
    fill(colorfondo); stroke(colorfondo);
    triangle(270-5,270-5,270-5,270+5,270+5,270);
    textFont(f,8);
    fill(255); text("Play",262,292);
    strokeWeight(1);
    if(mouseX>(270-24) && mouseX<(270+24) && mouseY>(270-24) && mouseY<(270+24) ) {
      stroke(128); fill(128);
      ellipse(270,270,28,28);
      fill(255); stroke(255);
      triangle(270-5,270-5,270-5,270+5,270+5,270);
      if(mousePressed==true) {
        if(pausado==true) {
          pausado=false;
        } else {
          pausado=true;
        }  
      }  
    } 
    strokeWeight(1); 
    
  }  
 
  
  //Boton reset
  stroke(128); fill(255);
  ellipse(270,236,28,28);
  fill(colorfondo); textFont(f,8);
  text("Reset",258,239);  
  strokeWeight(1);
  if(mouseX>(270-24) && mouseX<(270+24) && mouseY>(236-24) && mouseY<(236+24) ) {
    stroke(128); fill(128);
    ellipse(270,236,28,28);
    fill(255); textFont(f,8);
    text("Reset",258,239);
    if(mousePressed==true) {
     ((slider) tools.find("Speed")).setVal(0.25) ;
     //((slider) tools.find("Pharmacist effort (hours)")).setVal(2) ;
     ((slider) tools.find("% Lethal ")).setVal(0) ;  
     ((slider) tools.find("% Non Significant")).setVal(33) ;
     ((slider) tools.find("% Significant")).setVal(64) ;
     ((slider) tools.find("% Serious")).setVal(3) ;
     ((slider) tools.find("% Admission")).setVal(27) ;
     ((slider) tools.find("% Acceptance")).setVal(84) ;
    }  
  }
  strokeWeight(1);  
  
  annotate();
    
} // end draw()



void mousePressed() {
  boolean captured = tools.offerMousePress();  
}

void mouseReleased() {
  botonsoltado = true;
}

void annotate() {
     stroke(darken(colorfondo)); fill(darken(colorfondo));
     ellipse(30,30,40,40);
     stroke(240); fill(240);
     triangle(24,20,24,40,44,30);
     stroke(darken(darken(darken(colorfondo)))); fill(darken(darken(darken(colorfondo))));
     textFont(f,24);
     text("Play", 30, 25);
     textFont(f,18);
     text("With",3,40);
     textFont(f,22);
     text("me",35,50);   
      
     line(width-300,140,width-5,140);
     line(width-300,140,width-300,280);
     line(width-5,140,width-5,280);
     line(width-300,280,width-300+70,280);
     line(width-5-70,280,width-5,280);
 
     line(20,135,240,135);
     line(20,135,20,280);
     line(20,280,240,280);
     line(240,135,240,152);
     line(240,280,240,185);

     textFont(f,12);
     text("External",215,165);
     text("factors",215,180);
     text("Severity of the MRP",width-215,285);
          
     text("A simple model to",95,30);
     text("analyze the hospital",95,45);
     text("avoided costs by a",95,60);
     text("pharmacist in an",95,75);
     text("Emergency Department.",95,90);
     
     textFont(f,9);
     text("Based on data taken in the Observation Unit of a Hospital",20,110);
     text("during " + time_year[1],20,125);
     
     textFont(f,9);
     text("Original work by Dr. Marisol Ucha & Dr. Pablo Otero",width/2,height-5);
}


