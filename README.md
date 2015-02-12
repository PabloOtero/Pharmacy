This tool allows visualizing the avoided costs by a Pharmacist integrated in a multidisciplinary team of an Emergency Department. The idea behind this tool is to show (and help to Health Planners) to understand the importance of integrating this kind of professional in the multidisciplinary team of this Unit. 

You can play with data taken during 2012 in a Spanish Hospital in www.caringandsaving.com.

Or, if you are a Pharmacist, you can take you own data and use this tool to visualize. In that case you have two options:
A)	Download the “web-export” folder. Open the spreadsheets files (*.xls) named “parameters” and “data”.  In the first case, modify the parameters and save with the same name but as tabular separated text (parameters.txt). In the second one, do the same: modify and save as data.txt. Upload the complete folder to a server (or run local using some tool as Ampps). Open index.html in your browser. Play with it!
B)	Download Processing from www.processing.org. Create a folder named “Pharmacy” and include inside all the files and subfolders of this repository. Modify “parameters.txt” and “data.txt” and shown above. Open “Pharmacy.pde” with Processing and run the sketch in Javascript mode.
NOTES:
EXPLANATION OF THE PARAMETERS FILE
-	Hospitalization cost per patient and per day: this is the overall costs of the patient in euros.
-	Mean days of hospitalization: compute this value from your won data. 
-	Risk of increased hospital stay in case of lethal MRP (%)	: MRP means Medicament Related Problem. Here, we have obtained the values from Bates et al. Incidence of adverse drug events and potential adverse drug events. Implications for prevention. JAMA. 1995; 274: 29-34.
-	Risk of increased hospital stay in case of serious MRP (%): same than above
-	Risk of increased hospital stay in case of significant MRP (%): same than above
-	Risk of increased hospital stay in case of non-significant MRP (%): should be zero
-	Mean acceptance (%) of the pharmacist reccomendations by the emergency department: compute this value form your own experience.
-	Mean admission (%) in a Hospital Unit after passing through the Observation Unit: how many patients pass to a different Hospital Unit	after entering in the Emergency Department?
-	How much dollars is 1 euro?: Google knows…
-	Define threshold of minimum air temperature (ºC) to describe colder days: come on, select this value based on your own experience. It is just for fun!
-	Define threshold of maximum air temperature (ºC) to describe warmer days: 	similar to above.
-	Define minimum difference among max and min temperature in days with strong thermal oscillation: obviously this depends on your location. Do not modify if you do not have idea about what value.

EXPLANATION OF THE DATA FILE
-	Date (first column): include the complete series of days from your start to your end date of your study. The format must be DD/MM/YYYY. You can include a whole year or just a shorter period.
-	Patients (second column): this is the number of patients entering each day in the Emergency Unit.
-	Interventions (third column): this is the number of patients who experienced intervention by the Pharmacist. What if you did not take records one day? Just type -9999. The tool will interpolate data with some random value (although based on your statistics)
-	Min. daily temperature (ºC): you can obtain these records from you meteorological service operating in your area. Otherwise, skip this step and omit this analysis.
-	Max. daily temperature (ºC): same than above.




