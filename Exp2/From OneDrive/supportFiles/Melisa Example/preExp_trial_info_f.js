//Create pre-exposure list, put familiar and known faces in the right indeces


var numFaces = 36; //this will be 36
var numContexts = 36; //this will also be 36
var numFacesCond = numFaces/3; //number of faces in each condition
var numPreExpTrials = (numFaces/3)*2*4; //number of trials in the pre-exposure phase

var faces = fillArray(-1, numFaces);
var contexts = fillArray(-1, numContexts);

//face numbers 1:36
for (var i=0; i<numFaces; i++){
	faces[i]=i+1;
	contexts[i]=i+1;
	}
	
faces = shuffle(faces);
contexts = shuffle(contexts);

//randomly assign each face to each familiarity condition
var famFaces = faces.slice(0, numFacesCond);
var knowFaces = faces.slice(numFacesCond, numFacesCond*2);
var unfamFaces = faces.slice(numFacesCond*2, numFaces);
var names = shuffle(["EMILY", "JESSICA", "ASHLEY", "SARAH", "SAMANTHA", "REBECCA", "HANNAH", 
"ALEXIS", "RACHEL", "KAYLA", "ELIZABETH", "MEGAN", "AMANDA", "BRITTANY", "MADISON", "LAUREN", 
"BRIANNA", "VICTORIA", "JENNIFER", "STEPHANIE", "COURTNEY","NICOLE", "ALYSSA", "CHLOE", "ZOEY","GRACE",
"SOFIA","AUDREY","HAZEL","PATRICIA","MARY","MARGARET","BETTY","LISA","KAREN","NANCY"
]);

//randomly assign contexts to each familiarity condition
var famContexts = contexts.slice(0, numFacesCond);
var knowContexts = contexts.slice(numFacesCond, numFacesCond*2);
var unfamContexts = contexts.slice(numFacesCond*2, numFaces);

//randomly assign each face in each fam condition to same or different context 
var famFaceSame = famFaces.slice(0,numFacesCond/2);
var famFaceDiff = famFaces.slice(numFacesCond/2, numFacesCond);//familiar faces that will be presented with a different context at test
var knowFaceSame = knowFaces.slice(0,numFacesCond/2); 
var knowFaceDiff = knowFaces.slice(numFacesCond/2, numFacesCond);
var unfamFaceSame = unfamFaces.slice(0,numFacesCond/2);
var unfamFaceDiff = unfamFaces.slice(numFacesCond/2, numFacesCond);

//all faces in the same condition 

var sameCond = famFaceSame.concat(knowFaceSame).concat(unfamFaceSame); 

//the constrainedShuffle function is in shuffle_tools.js
//generate 0s and 1s such that no more than 2 0s or 1s follow each other
var preExp_PresentationOrder = constrainedShuffle(numPreExpTrials); 


//for changing presentation order of faces in each pre-exposure block
//first half of each block is familiar and the latter half known
var PreExpBlock1 =  famFaces.concat(knowFaces);
var PreExpBlock2 =  shuffle(famFaces).concat( shuffle(knowFaces) );
var PreExpBlock3 =  shuffle(famFaces).concat( shuffle(knowFaces) );
var PreExpBlock4 =  shuffle(famFaces).concat( shuffle(knowFaces) );



var preExp_b1 = []; //actual faces in their presentation order
//c1 and c2 are indeces to pull faces from PreExpBlockX
var c1 = 0;
var c2 = (numPreExpTrials/8); //4


	for(var i=0;i<(numPreExpTrials/4);i++) { //block 1
		if(preExp_PresentationOrder[i+0] == 0) //familiar
		{
			preExp_b1[i] = PreExpBlock1[c1]; //the first half (12) of each block consists of pics assigned to the familiar condition
			c1 += 1;
		}
		
		else if(preExp_PresentationOrder[i+0] == 1) //know
		
		{
			preExp_b1[i] = PreExpBlock1[c2];
			c2 += 1;
		}
		
	};
	
var preExp_b2 = []; 
	c1 = 0;
	c2 = (numPreExpTrials/8);
	for(var i=0;i<(numPreExpTrials/4);i++) {
		if(preExp_PresentationOrder[i+(numPreExpTrials/4)] == 0)
		{
			preExp_b2[i] = PreExpBlock2[c1];
			c1 += 1;
		}
		else if(preExp_PresentationOrder[i+(numPreExpTrials/4)] == 1)
		{
			preExp_b2[i] = PreExpBlock2[c2];
			c2 += 1
		}
	}	
	
var preExp_b3 = []; 
	c1 = 0;
	c2 = (numPreExpTrials/8);
	for(var i=0;i<(numPreExpTrials/4);i++) {
		if(preExp_PresentationOrder[i+(2*numPreExpTrials/4)] == 0)
		{
			preExp_b3[i] = PreExpBlock3[c1];
			c1 += 1;
		}
		else if(preExp_PresentationOrder[i+(2*numPreExpTrials/4)] == 1)
		{
			preExp_b3[i] = PreExpBlock3[c2];
			c2 += 1
		}
	}	
		
var preExp_b4 = []; 
	c1 = 0;
	c2 = (numPreExpTrials/8);
	for(var i=0;i<(numPreExpTrials/4);i++) {
		if(preExp_PresentationOrder[i+(3*numPreExpTrials/4)] == 0)
		{
			preExp_b4[i] = PreExpBlock4[c1];
			c1 += 1;
		}
		else if(preExp_PresentationOrder[i+(3*numPreExpTrials/4)] == 1)
		{
			preExp_b4[i] = PreExpBlock4[c2];
			c2 += 1
		}
	}	
		
//preExpFaces are the actual faces that are gonna be presented in the order in which they will be presented
var preExpFaces = preExp_b1.concat(preExp_b2).concat(preExp_b3).concat(preExp_b4);
	
