function prepdata(data) {
  var datacsv = "";
  var labels = Object.keys(data); //grabs all the properties of data

  for (n = 0; n < labels.length; n++){
    datacsv = datacsv + labels[n] + ','; // 'col1', 'col2'
  }
  datacsv = datacsv + '\n'; //next line

  
 let ntoloop = data[Object.keys(data)[0]].length;
  
  //let ntoloop = 5
  for (n = 0; n < ntoloop; n++){
    for (var i in data){
      if (data.hasOwnProperty(i)){
        datacsv = datacsv + data[i][n] + ','; //in "str" + num, num is converted to a string.
      }
    }
    datacsv = datacsv + '\n';
  }

  return datacsv;
};



function getAvg(arr) {
 
	var len = arr.length;
	 
	if(len==0) return[];
	 

	var sum = 0;
	 
	for (var i=0; i<len; i++){
		 
		sum = sum + arr[i]
		  
	 };
	 
	var mean = sum/len;
 
	return mean;

}

function shuffle(unshuffled) {
	for (var i = unshuffled.length - 1; i > 0; i--) {
		var j = Math.floor(Math.random() * (i + 1));
		var temp = unshuffled[i];
		unshuffled[i] = unshuffled[j];
		unshuffled[j] = temp;
	}
	return unshuffled;
}

function fillArray(value, len){
	if (len==0) return [];
	var arr = [value];
	for (var i=0; i<len-1; i++){
		arr.push(value);
		}
		return arr;
}



var pick = -1;



function genProb(){
	
	var operations = ['+', '-'];
	
	var operate1 = operations[Math.floor(Math.random()*2)];
	var operate2 = operations[Math.floor(Math.random()*2)];
	
	 var p1 = Math.floor(Math.random()*50);
	 var p2 = Math.floor(Math.random()*10);
	 var p3 = Math.floor(Math.random()*3);
	
	var cor_answer = eval(p1 + operate1 + p2)*p3;
	var error_array = [-5,-4,-3,-2,-1,1,2,3,4,5];
	var incor_answer = cor_answer + error_array[Math.floor(Math.random()*10)];
	
	var answers = [cor_answer,incor_answer];
	
	pick = Math.floor(Math.random()*2); //0 correct, 1 incorrect
	
	return '(' + p1 + ' ' + operate1 + ' ' +  p2 + ')'+ ' x ' + p3 + ' = ' + answers[pick] ;
	
console.log('pick: ' + pick);	
}
/////// For study presentation order of familiar and unfamiliar conditions
/// no more than two familiar or two unfamiliar faces presented subsequently

///*
function constrainedShuffle (numTrials){
	
	var constrained = fillArray(0, numTrials)
	
	constrained[0]= Math.floor(Math.random()*2);
	constrained[1]= Math.floor(Math.random()*2);
	
	var sum=0;
	
	while (sum !=numTrials/2) {
		
		sum=0;
		for (var i=2; i<numTrials; i++){
			
			if (constrained[i-2]==0 && constrained[i-1]==0){
				constrained[i]=1;			
			}else if (constrained[i-2]==1 && constrained[i-2]==1){
				constrained[i]=0;
			}else{
				constrained[i]=Math.floor(Math.random()*2);
			}

		}
		
		for (var j=0; j < (numTrials); j++){
			sum = sum + constrained[j];
		}
		
	}
	return constrained;
	
}


//males = 1:20
//females= 21:40

var n = 40; // total number of faces; this will be 40
var males = new Array(n/2);
var females= new Array(n/2);



for (var i=0; i<males.length; i++){
	males[i] = i+1;
	females[i] = i+1+(n/2);
}
//male photos will be named from 1 to 20
//and female photos will be named from 21 to 40
males = shuffle(males);
females = shuffle(females);

//familiar faces
var old_fam_males = males.slice(0,5) //old (criminal) familiar males
var old_fam_females = females.slice(0,5); // ^^ females
var new_fam_males = males.slice(5,10); //new (innocent) familiar males
var new_fam_females = females.slice(5,10);//^^ females
//all familiar faces (criminal and innocent), this will be 20 faces
var fam_faces = shuffle(old_fam_males.concat(old_fam_females).concat(new_fam_males).concat(new_fam_females));

// unfamiliar faces
var old_unfam_males = males.slice(10,15) //old (criminal) familiar males
var old_unfam_females = females.slice(10,15); // ^^ females
var new_unfam_males = males.slice(15,20); //new (innocent) familiar males
var new_unfam_females = females.slice(15,20);//^^ females
//all unfamiliar faces (criminal and innocent), this will be 20 faces
var unfam_faces = shuffle(old_unfam_males.concat(old_unfam_females).concat(new_unfam_males).concat(new_unfam_females));

var old_faces = old_fam_males.concat(old_fam_females).concat(old_unfam_males).concat(old_unfam_females);
//faces presented at pre-exposure phase, in order. 6 repetitions, each time, the order is shuffled

var pre_exp_faces = fam_faces.concat(shuffle(fam_faces)).concat(shuffle(fam_faces)).concat(shuffle(fam_faces)).concat(shuffle(fam_faces)).concat(shuffle(fam_faces));

var img_order = shuffle([1,2,3,4,5,6,7,8]);

var female_names = shuffle(["EMILY", "JESSICA", "ASHLEY", "SARAH", "CHLOE", "GRACE", "AMANDA", "ZOEY", "JULIE", "LAUREN",
							"AMBER", "DIANA", "ROSE", "JUDY", "EVELYN", "DENISE","JANE", "FRANCES", "LORY", "NATALIE"]);
var male_names = shuffle(["OLIVER","GABRIEL","CARTER","LARRY","TYLER","ALLEN","LOGAN","WAYNE", "ROBERT", "ANDREW",
						  "JACOB", "BRANDON", "CHRIS", "JOSH","KYLE", "MICHAEL", "NICK", "RYAN", "JOHN", "KEVIN" ]);
						  

						  
// there will be 20 male names, 20 female names
var names = shuffle(male_names).concat(shuffle(female_names));

//~~~~STUDY~~~~\\
//to be studied familiar and unfamiliar faces in random order

var old_fam_faces = shuffle(old_fam_males.concat(old_fam_females));
var old_unfam_faces = shuffle(old_unfam_males.concat(old_unfam_females));

var study_faces = new Array(n/2);// 20 faces

var study_order = constrainedShuffle(n/2); //order of unfamiliar and familiar conditions

//0 = unfamiliar; 1=familiar
var u=0;
var f=0;

for (var i=0; i<n/2; i++){
	
	if (study_order[i]==0){
		study_faces[i]= old_unfam_faces[u];
		u=u+1;
		
	}else if(study_order[i]==1){
		study_faces[i]= old_fam_faces[f];
		f=f+1;
	}
}

//~~~TEST~~~\\

var new_fam_faces = shuffle(new_fam_males.concat(new_fam_females)); //10 faces
var new_unfam_faces = shuffle(new_unfam_males.concat(new_unfam_females)); //10 faces
var old_fam_faces_shuffled = shuffle(old_fam_faces);
var old_unfam_faces_shuffled = shuffle(old_unfam_faces);

//var test_half_1 = shuffle(old_fam_faces.slice(0,9).concat(new_fam_faces.slice(0,9)).concat(shuffle(old_unfam_faces).slice(0,9)).concat(new_unfam_faces.slice(0,9)));

var test_half_1 = shuffle(old_fam_faces_shuffled.slice(0,5).concat(new_fam_faces.slice(0,5)).concat(old_unfam_faces_shuffled.slice(0,5)).concat(new_unfam_faces.slice(0,5)));
var test_half_2 = shuffle(old_fam_faces_shuffled.slice(5,10).concat(new_fam_faces.slice(5,10)).concat(old_unfam_faces_shuffled.slice(5,10)).concat(new_unfam_faces.slice(5,10)));


var test_faces = test_half_1.concat(test_half_2);

var status_test = fillArray(1,test_faces.length); //make all faces new, the study status condition of each item at test in order
var fam_test = fillArray(1,test_faces.length); //make all faces familiar, the familiarity condition of each item at test in order

for (var i=0; i<test_faces.length;i++){
	
	if (old_faces.includes(test_faces[i])){
		status_test[i]= 0 // old= 0
	
	}
	
	if (unfam_faces.includes(test_faces[i]))
		fam_test[i]=0
		
	}
	
	

						  