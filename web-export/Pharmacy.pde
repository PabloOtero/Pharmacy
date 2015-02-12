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


void MRP_evaluation() {
  
    ////////////////////////////////
  /// Evaluate the per cent of MRP
  ////////////////////////////////
  if( (lethal_old!=lethal || serious_old!=serious || significant_old!=significant || nonsignificant_old!=nonsignificant) ) {
    
    //If lethal changes, the rest of field vary
    if(lethal_old!=lethal) {  
        reparto =  100-lethal;
        if(lethal>lethal_old) {
           float ponderador = nonsignificant+significant+serious;
           kk1=reparto*nonsignificant/ponderador;
           kk2=reparto*significant/ponderador;
           kk3=reparto*serious/ponderador;
           kk1=reparto-kk2-kk3;
        } 
        else {
           float ponderador = 300-nonsignificant-significant-serious;
           kk1=reparto*(100-nonsignificant)/ponderador;
           kk2=reparto*(100-significant)/ponderador;
           kk3=reparto*(100-serious)/ponderador;
           kk1=reparto-kk2-kk3;
        }   
     ((slider) tools.find("% Lethal ")).setVal(lethal) ;  
     ((slider) tools.find("% Non Significant")).setVal(kk1) ;
     ((slider) tools.find("% Significant")).setVal(kk2) ;
     ((slider) tools.find("% Serious")).setVal(kk3) ;
    } 

    //If "serious" changes, vary all the fields except lethal
    if(serious_old!=serious) {      
      if(serious==100) { 
        kk1 = 0; kk2=0; kk3=0; 
      } else {
        if( (serious+lethal)>100 ) {
          lethal=0;
        }  
        reparto =  100-serious-lethal;
        if(serious>serious_old) {
           float ponderador = nonsignificant+significant;
           kk2=reparto*significant/ponderador;
           kk3=lethal;
           kk1=reparto-kk2-kk3;
        } 
        else {
           float ponderador = 200-nonsignificant-significant;
           kk2=reparto*(100-significant)/ponderador;
           kk3=lethal;
           kk1=reparto-kk2-kk3;
        }   
      }
     ((slider) tools.find("% Non Significant")).setVal(kk1) ;
     ((slider) tools.find("% Significant")).setVal(kk2) ;
     ((slider) tools.find("% Serious")).setVal(serious) ;
     ((slider) tools.find("% Lethal ")).setVal(kk3) ;
    } 

    //If "significant" changes, vary all the fields except lethal
    if(significant_old!=significant) {  
      if(significant==100) { 
        kk1 = 0; kk2=0; kk3=0; 
      } else {
        if( (significant+lethal)>100 ) {
          lethal=0;
        }  
        reparto =  100-significant-lethal;
        if(significant>significant_old) {
           float ponderador = nonsignificant+serious;
           kk2=reparto*serious/ponderador;
           kk3=lethal;
           kk1=reparto-kk2-kk3;
        } 
        else {
           float ponderador = 200-nonsignificant-serious;
           kk2=reparto*(100-serious)/ponderador;
           kk3=lethal;
           kk1=reparto-kk2-kk3;
        }   
      }       
     ((slider) tools.find("% Non Significant")).setVal(kk1) ;
     ((slider) tools.find("% Significant")).setVal(significant) ;
     ((slider) tools.find("% Serious")).setVal(kk2) ;
     ((slider) tools.find("% Lethal ")).setVal(kk3) ;
    } 
 
 
     //If "nonsignificant" changes, vary all the fields except lethal
    if(nonsignificant_old!=nonsignificant) {  
      if(nonsignificant==100) { 
        kk1 = 0; kk2=0; kk3=0; 
      } else {
        if( (nonsignificant+lethal)>100 ) {
          lethal=0;
        }  
        reparto =  100-nonsignificant-lethal;
        if(nonsignificant>nonsignificant_old) {
           float ponderador = significant+serious;
           kk2=reparto*serious/ponderador;
           kk3=lethal;
           kk1=reparto-kk2-kk3;
        } 
        else {
           float ponderador = 200-significant-serious;
           kk2=reparto*(100-serious)/ponderador;
           kk3=lethal;
           kk1=reparto-kk2-kk3;
        }   
      }       
     ((slider) tools.find("% Non Significant")).setVal(nonsignificant) ;
     ((slider) tools.find("% Significant")).setVal(kk1) ;
     ((slider) tools.find("% Serious")).setVal(kk2) ;
     ((slider) tools.find("% Lethal ")).setVal(kk3) ;
    } 
 
    lethal =  (int) ( ((slider) tools.find("% Lethal ")).getVal() );
    serious =  (int) ( ((slider) tools.find("% Serious")).getVal() );
    significant = (int) ( ((slider) tools.find("% Significant")).getVal() );
    nonsignificant = (int) ( ((slider) tools.find("% Non Significant")).getVal() );
    
    lethal_old = lethal;
    serious_old = serious;
    significant_old = significant;
    nonsignificant_old = nonsignificant;
    
    botonsoltado=false;
  }  
  
  
}
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

/*
 * ----------------------------------
 *  Radio Button Class for Processing 2.0
 * ----------------------------------
 *
 * this is a simple radio button class. The following shows 
 * you how to use it in a minimalistic way.
 *
 * DEPENDENCIES:
 *   N/A
 *
 * Created:  April, 12 2012
 * Author:   Alejandro Dirgan
 * Version:  0.14
 *
 * License:  GPLv3
 *   (http://www.fsf.org/licensing/)
 *
 * Follow Us
 *    adirgan.blogspot.com
 *    twitter: @ydirgan
 *    https://www.facebook.com/groups/mmiiccrrooss/
 *    https://plus.google.com/b/111940495387297822358/
 *
 * DISCLAIMER **
 * THIS SOFTWARE IS PROVIDED TO YOU "AS IS," AND WE MAKE NO EXPRESS OR IMPLIED WARRANTIES WHATSOEVER 
 * WITH RESPECT TO ITS FUNCTIONALITY, OPERABILITY, OR USE, INCLUDING, WITHOUT LIMITATION, ANY IMPLIED 
 * WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR INFRINGEMENT. WE EXPRESSLY 
 * DISCLAIM ANY LIABILITY WHATSOEVER FOR ANY DIRECT, INDIRECT, CONSEQUENTIAL, INCIDENTAL OR SPECIAL 
 * DAMAGES, INCLUDING, WITHOUT LIMITATION, LOST REVENUES, LOST PROFITS, LOSSES RESULTING FROM BUSINESS 
 * INTERRUPTION OR LOSS OF DATA, REGARDLESS OF THE FORM OF ACTION OR LEGAL THEORY UNDER WHICH THE LIABILITY 
 * MAY BE ASSERTED, EVEN IF ADVISED OF THE POSSIBILITY OR LIKELIHOOD OF SUCH DAMAGES.
*/


/*
 this is a simple radio button class. The following shows you how to use it in a minimalistic way.


String[] options = {"First","Second","Third", "Fourth"}; 
ADradio radioButton;
int radio;


PFont output; 

void setup()
{
  size(300,300);
  smooth();
  output = createFont("Arial",24,true);  

  radioButton = new ADradio(117, 78, options, "radioButton"); 
  radioButton.setDebugOn();
  radioButton.setBoxFillColor(#F7ECD4);  
  radioButton.setValue(1);

}

void draw()
{
  background(#FFFFFF);

  radioButton.update();

  textFont(output,24);   
  text(options[radioButton.getValue()], (width-textWidth(options[radioButton.getValue()]))/2, height-20);

}


*/

class ADRadio
{
  
  color externalCircleColor=#000000;
  color externalFillCircleColor=#FFFFFF;
  color internalCircleColor=#000000;
  color internalFillCircleColor=#000000;
  
  boolean fillExternalCircle=false;
  
  PFont rText;
  color textColor=#000000;
  color textShadowColor=#7E7E7E;
  boolean textShadow=false;
  int textPoints=12;
  
  int xTextOffset=20;
  int yTextSpacing=14;
  
  int circleRadius=12;
  float circleLineWidth=0.5;
 
  float boxLineWidth=0.2;
  boolean boxFilled=false;
  color boxLineColor=#000000;
  color boxFillColor=#F4F5D7;
  boolean boxVisible=false;
  
  String[] radioText;
  boolean[] radioChoose; 
  
  int over=0;
  int nC;
  
  int rX, rY;
  
  float maxTextWidth=0;
  
  String radioLabel;
  
  boolean debug=false;
  
  int boxXMargin=5;
  int boxYMargin=5;
  
  int bX, bY, bW, bH;
  boolean pressOnlyOnce=true;
  int deb=0;    
  
///////////////////////////////////////////////////////  
  ADRadio(int x, int y, String[] op, String id)
  {
    rX=x;
    rY=y;
    radioText=op;
    
    nC=op.length;
    radioChoose = new boolean[nC];
        
    rText = createFont("Arial",16,true);      
    textFont(rText,textPoints);   
    textAlign(LEFT);
    
    for (int i=0; i<nC; i++) 
    {
      if (textWidth(radioText[i]) > maxTextWidth) maxTextWidth=textWidth(radioText[i]);
      radioChoose[i]=false;
    }
    
    radioChoose[over]=true;
    
    radioLabel=id;
    
    calculateBox();
    
  }
  
///////////////////////////////////////////////////////  
  void calculateBox()
  {
    bX=rX-circleRadius/2-boxXMargin;
    bY=rY-circleRadius/2-boxYMargin;
    bW=circleRadius*2+xTextOffset+(int )maxTextWidth;
    bH=radioText.length*circleRadius + (radioText.length-1)*yTextSpacing + boxYMargin*2;
  }  
///////////////////////////////////////////////////////  
  void setValue(int n)
  {
    if (n<0) n=0;
    if (n>(nC-1)) n=nC-1;
    
   for (int i=0; i<nC; i++) radioChoose[i]=false;
   radioChoose[n]=true;  
   over=n; 
  }
///////////////////////////////////////////////////////  
  void deBounce(int n)
  {
    if (pressOnlyOnce) 
      return;
    else
      
    if (deb++ > n) 
    {
      deb=0;
      pressOnlyOnce=true;
    }
    
  }  ///////////////////////////////////////////////////////  
  boolean mouseOver()
  {
    boolean result=false; 
    
    if (debug)
      if ((mouseX>=bX) && (mouseX<=bX+bW) && (mouseY>=bY) && (mouseY<=bY+bH))
      {
        if (mousePressed && mouseButton==LEFT && keyPressed)
        {
          if (keyCode==CONTROL)
          {
            rX=rX+(int )((float )(mouseX-pmouseX)*1);
            rY=rY+(int )((float )(mouseY-pmouseY)*1);
            calculateBox();
          }
          if (keyCode==SHIFT && pressOnlyOnce) 
          {
            printGeometry();
            pressOnlyOnce=false;
          }
          deBounce(5);
          
        }
      }
      
    for (int i=0; i<nC; i++)
    {
      if ((mouseX>=(rX-circleRadius)) && (mouseX<=(rX+circleRadius)) && (mouseY>=(rY+(i*(yTextSpacing+circleRadius))-circleRadius)) && (mouseY<=(rY+(i*(yTextSpacing+circleRadius))+circleRadius)))
      {
        result=true;
        
        if (mousePressed && mouseButton==LEFT && pressOnlyOnce)
        {
          over=i;
          setValue(over);
          pressOnlyOnce=false;
        }
        deBounce(5);
        i=nC;
      }
      else
      {
        result=false;
      }
    } 
    return result;
  }
///////////////////////////////////////////////////////  
  void drawBox()
  {
    if (!boxVisible) return;
    if (boxFilled)
      fill(boxFillColor);
    else
      noFill();
    strokeWeight(boxLineWidth);
    stroke(boxLineColor);

    rect(bX, bY, bW, bH);

  }  
///////////////////////////////////////////////////////  
  void drawCircles()
  {
    strokeWeight(circleLineWidth);
    for (int i=0; i<nC; i++)
    {
      if (!fillExternalCircle) 
        noFill();
      else
        fill(externalFillCircleColor);  
      stroke(externalCircleColor);  
      ellipse(rX, rY+(i*(yTextSpacing+circleRadius)), circleRadius, circleRadius);

      fill(internalFillCircleColor);
      stroke(internalCircleColor);  

      if (radioChoose[i])
         ellipse(rX, rY+(i*(yTextSpacing+circleRadius)), circleRadius-8, circleRadius-8);
    }
    mouseOver();
   
  }
///////////////////////////////////////////////////////  
  void drawText()
  {
    float yOffset=rY+textPoints/3+1;
    stroke(textColor);
    textFont(rText,textPoints);   
    textAlign(LEFT);

    for (int i=0; i<nC; i++)
    {
      if (textShadow)
      {
        stroke(textShadowColor);
        text(radioText[i], rX+xTextOffset+1, yOffset+(i*(yTextSpacing+circleRadius))+1);
        stroke(textColor);
      }
      text(radioText[i], rX+xTextOffset, yOffset+(i*(yTextSpacing+circleRadius)));
    }
    
  }  
  
///////////////////////////////////////////////////////  
  int update()
  {
    drawBox();
    drawCircles();
    drawText();
    
    return over;
  }

///////////////////////////////////////////////////////  
  int getValue()
  {
    return over;
  }
 
///////////////////////////////////////////////////////  
  void setDebugOn()
  {
    debug=true;
  }
///////////////////////////////////////////////////////  
  void setDebugOff()
  {
    debug=false;
  }
///////////////////////////////////////////////////////  
  void printGeometry()
  {
    println("radio = new ADradio("+rX+", "+rY+", arrayOfOptions"+", \""+radioLabel+"\");");

  }
///////////////////////////////////////////////////////  
  void setExternalCircleColor(color c)
  {
    externalCircleColor=c;
  }
///////////////////////////////////////////////////////  
  void setExternalFillCircleColor(color c)
  {
    externalFillCircleColor=c;
  }
///////////////////////////////////////////////////////  
  void setInternalCircleColorr(color c)
  {
    externalFillCircleColor=c;
  }
///////////////////////////////////////////////////////  
  void setInternalFillCircleColor(color c)
  {
    externalFillCircleColor=c;
  }
///////////////////////////////////////////////////////  
  void setTextColor(color c)
  {
    textColor=c;
  }
///////////////////////////////////////////////////////  
  void setTextShadowColor(color c)
  {
    textShadowColor=c;
  }
///////////////////////////////////////////////////////  
  void setShadowOn()
  {
    textShadow=true;
  }
///////////////////////////////////////////////////////  
  void setShadowOff()
  {
    textShadow=false;
  }
///////////////////////////////////////////////////////  
  void setTextSize(int s)
  {
    textPoints=s;
  }
///////////////////////////////////////////////////////  
  void setXTextOffset(int s)
  {
    xTextOffset=s;
  }
///////////////////////////////////////////////////////  
  void setyTextSpacing(int s)
  {
    yTextSpacing=s;
  }
///////////////////////////////////////////////////////  
  void setCircleRadius(int s)
  {
    circleRadius=s;
  }
///////////////////////////////////////////////////////  
  void setBoxLineWidth(int s)
  {
    boxLineWidth=s;
  }
///////////////////////////////////////////////////////  
  void setBoxLineColor(color c)
  {
    boxLineColor=c;
  }
///////////////////////////////////////////////////////  
  void setBoxFillColor(color c)
  {
    boxFillColor=c;
    setBoxFilledOn();
  }
///////////////////////////////////////////////////////  
  void setBoxFilledOn()
  {
    boxFilled=true;
  }
///////////////////////////////////////////////////////  
  void setBoxFilledOff()
  {
    boxFilled=false;
  }
///////////////////////////////////////////////////////  
  void setBoxVisibleOn()
  {
    boxVisible=true;
  }
///////////////////////////////////////////////////////  
  void setBoxVisibleOff()
  {
    boxVisible=false;
  }
///////////////////////////////////////////////////////  
  void setLabel(String l)
  {
    radioLabel=l;
  }

}


