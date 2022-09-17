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

function arr_diff (a1, a2) {

    var a = [], diff = [];

    for (var i = 0; i < a1.length; i++) {
        a[a1[i]] = true;
    }

    for (var i = 0; i < a2.length; i++) {
        if (a[a2[i]]) {
            delete a[a2[i]];
        } else {
            a[a2[i]] = true;
        }
    }

    for (var k in a) {
        diff.push(k);
    }

    return diff;
}



//constrained shuffle creates an array of zeros and ones such that no more than 2 zeros or 2 ones can follow each other.
// The length is numTrials long. 
// numTrials is the number of trials (face presentations in pre-exposure)
// the array that is returned is called constrained.

function constrainedShuffle (numTrials){
	//console.log("Constrained shuffle with " + numTrials + " trials");
	var constrained = [];
	for(var i=0;i<numTrials;i++)
	{
		constrained[i] = 0;
	}
	//console.log("Constrained: " + constrained);
	var sum = -1;
	
	// if we need 8 total 1/s 0/s  0 1 0 1 0 1 0 1
	// and we must have 4 sum
	// [ 1 1 0 1 1 0 0 1 ]
	//console.log("While sum less than " + (1*numTrials/8) );
	while (sum != 1*numTrials/8) // 26   /// while sum != 0
	{
		sum = 0;
		
		constrained[0] = Math.floor(Math.random()*2);
		constrained[1] = Math.floor(Math.random()*2);
		//console.log("Primed: " + constrained);
		for (var i=2; i<(numTrials/4); i++)
		{
			if (constrained[i-2]==0 && constrained[i-1]==0){							
				constrained[i]=1;
			}else if (constrained[i-2]==1 && constrained[i-1]==1){
				constrained[i]=0;
			}else{
				constrained[i]= Math.floor(Math.random()*2);
			}
			//console.log("For loop looping " + constrained);
		}

		//console.log("Summing");
		for (var j=0; j < (numTrials/4); j++){
			sum = sum + constrained[j];
		}
		//console.log("Sum is " + sum);
	}
	
	while (sum != 2*numTrials/8) {
		for (var i=(numTrials/4); i<(numTrials/2); i++) {
			if (constrained[i-2]==0 && constrained[i-1]==0){
				constrained[i]=1;
			}else if (constrained[i-2]==1 && constrained[i-1]==1){
				constrained[i]=0;
			}else{
				constrained[i]=Math.floor(Math.random()*2);
			}
		}
		
		sum = 0;	
		for (var j=0; j<(numTrials/2); j++){
			sum = sum + constrained[j];
		}
	}

	/////////////////////////////////
	
	while (sum != numTrials*(3/8))
	{
		for (var i=(numTrials/2); i<(numTrials*0.75); i++)
		{
			if (constrained[i-2]==0 && constrained[i-1]==0){
				constrained[i]=1;
			}else if (constrained[i-2]==1 && constrained[i-1]==1){
				constrained[i]=0;
			}else{
				constrained[i]=Math.floor(Math.random()*2);
			}
		}
		
		sum = 0;
		for (var j=0; j<(numTrials*0.75); j++){
			sum = sum + constrained[j];
		}
	}


	////////////////////////////////

	while (sum != 4*numTrials/8)
	{
		for (var i=(numTrials*0.75); i<numTrials; i++)
		{
			if (constrained[i-2]==0 && constrained[i-1]==0){
				constrained[i]=1;
			}else if (constrained[i-2]==1 && constrained[i-1]==1){
				constrained[i]=0;
			}else{
				constrained[i]=Math.floor(Math.random()*2);
			}
		}

		sum = 0;			
		for (var j=0; j<numTrials; j++){
			sum = sum + constrained[j];
		}
	}

	return constrained;

};

//count the frequency of the element i, in the array a
function count(a,i){
	var result=0;
	
	for (var x in a){
		if (a[x] == i){
			result++;
	
		}
		
	}
		return result;
}



function construct_study_array_v2(){
 
numTrials = 36; //36

conds = [0,1,2];
var study_list = fillArray(-1, numTrials);



var totalOnes = 0;
var totalTwos =0;
var totalZeros =0;
//block 2
var totalOnes_b2 = 0;
var totalTwos_b2 =0;
var totalZeros_b2 =0;

	
study_list[0] = Math.floor(Math.random()*3);//put 0,1 or 2
study_list[1] = Math.floor(Math.random()*3);


var three_in_a_row = false;

while(totalOnes !== numTrials/3 || totalTwos !== numTrials/3 || totalZeros !== numTrials/3 || three_in_a_row==true) {
	
		var totalOnes = 0;
		var totalTwos =0;
		var totalZeros =0;
		
	
	for (var n=2; n<study_list.length; n++){
	
		if (study_list[n-2]==study_list[n-1]){
		
			
			var a = study_list[n-1]; //repeating element, say this is 1
			var b = conds.filter(el => el !== a); //array other than the repeating element, then this will be 0 and 2
			var c = b[Math.floor(Math.random()*2)]; //choose one at random
			
			study_list[n] = c;
		} else {
		study_list[n] = Math.floor(Math.random()*3);
		}
	
	totalOnes = count(study_list,1);
	totalTwos = count(study_list, 2);
	totalZeros= count(study_list, 0);
		
	
}

	
}

for (var n=2; n<study_list.length-2;n++){
			
			if ( study_list[n-2]==study_list[n-1] && study_list[n-1]==study_list[n]){
				three_in_a_row = true;
			}
		}


study_list_b2 = fillArray(-1,numTrials);

var study_list_f = study_list.concat(study_list_b2);



//block 2
	
while(totalOnes_b2 !== 2*numTrials/3 || totalTwos_b2 !== 2*numTrials/3 || totalZeros_b2 !== 2*numTrials/3 || three_in_a_row==true) {
	
	var totalOnes_b2 = 0;
	var totalTwos_b2 =0;
	var totalZeros_b2 =0;


	for (var m=study_list.length; m<study_list_f.length; m++){ 
		if (study_list_f[m-2]== study_list_f[m-1]){
			var d = study_list_f[m-1]; //repeating element
			var e = conds.filter(el=> el !==d);
			var f = e[Math.floor(Math.random()*2)];
			
			study_list_f[m]= f;
			
		}else {
			study_list_f[m]=Math.floor(Math.random()*3);
		}
		
	totalOnes_b2 = count(study_list_f,1);
	totalTwos_b2 = count(study_list_f, 2);
	totalZeros_b2 = count(study_list_f, 0);
	}

	
}


return study_list_f

};

