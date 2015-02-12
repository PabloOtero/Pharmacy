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
