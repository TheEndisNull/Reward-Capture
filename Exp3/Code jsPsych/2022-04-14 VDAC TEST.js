const jsPsych = initJsPsych({
    on_finish: function () {
        jsPsych.data.displayData();
    }
})

//sets reusable variables for screen width and height that avoids scrollbals
var wd = window.innerWidth * .95
var ht = wd * (9 / 16)
var keys = ['z', 'm']

var fixationStim = [{
    obj_type: 'line',
    startX: 0,
    startY: 0,
    line_length: 50,
    angle: 0,
    line_width: 5,
    line_color: 'black',
    origin_center: true,
}, {
    obj_type: 'line',
    startX: 0,
    startY: 0,
    line_length: 50,
    angle: 90,
    line_width: 5,
    line_color: 'black',
    origin_center: true,
}]

var fixation = {    //Generates fixation cross for 400 - 1000 ms
    type: jsPsychPsychophysics,
    trial_duration: Math.random() * (600 - 400) + 400,
    stimuli: fixationStim,
    data: jsPsych.timelineVariable('data'),
    canvas_width: wd,
    canvas_height: ht,
}

function drawVDACtest(tgtPos, rwdPos, tgtDir) {
    var cX = [.0 * ht, .3 * ht, 0 * ht, -.3 * ht]
    var cY = [-.3 * ht, .0 * ht, .3 * ht, 0 * ht]
    var cR = [.1 * ht, .09 * ht]
    //TESTTESTTEST shows position of rewarded item
    var colArr = (['black', 'black', 'black'])
    colArr.splice(rwdPos, 0, 'white')

    //Shuffles the order of diaganol lines, inserts target line
    var testValue = Math.floor(Math.random() * 2) + 1;
    switch (testValue) {
        case 1:
            var angle = [45, 45, -45];
            break;
        case 2:
            var angle = [45, -45, -45];
            break;
    }
    angle = jsPsych.randomization.shuffle(angle);

    if (tgtDir == 'h') {
        angle.splice(tgtPos, 0, '0')
    } else if (tgtDir == 'v') {
        angle.splice(tgtPos, 0, '90')
    }
    //Inserts circles and lines onto page, adds fixation cross and text. Returns stimulus
    var arrVDACstim = []
    arrVDACstim = arrVDACstim.concat(fixationStim);

    for (i = 0; i < 4; i++) {
        arrVDACstim.push({
            obj_type: 'circle',
            startX: cX[i],
            startY: cY[i],
            radius: cR[0],
            line_color: colArr[i],
            fill_color: 'grey',
            line_width: 7,
            origin_center: true,
        }, {
            obj_type: 'line',
            startX: cX[i],
            startY: cY[i],
            line_length: 50,
            line_width: 5,
            angle: angle[i],
            line_color: 'black',
            origin_center: true,
        }
        )
    }
    return arrVDACstim
}
//Reuses drawVDACtest, adds content for training phase
function drawVDACtrain(tgtPos, rwdPos, tgtDir) {
    var arrVDACstim = drawVDACtest(tgtPos, rwdPos, tgtDir)
    arrVDACstim.push({
        obj_type: 'text',
        startX: 'center',
        startY: .95 * ht,
        content: 'Press ' + keys[0] + ' for horizontal or ' + keys[1] + ' for vertical',
        show_end_time: 2000 // disappear this text
    })
    return arrVDACstim
}

// CONVERT THIS INTO PRERENDERED IMAGE FILE
var VDACinstructions = {
    type: jsPsychInstructions,
    pages: [
        '<div style= "font-size:20px;" <p> <strong> Welcome to the experiment! </strong><br> <p style="color:red; font-size:25px;"> Please do NOT exit full screen until you are done with the experiment. </p>' +
        '<p style="color:red;"> The experiment will be canceled and your data will be lost if you try to go back or refresh the page at any time during the experiment.</p>' +
        '<p style="color:red;"> Please rely on your memory and do NOT write anything down throughout the experiment. </p>' +
        '<br>' +
        '<p style="color:black;">Click next or use the arrow keys to proceed.</p> </span>'
    ],
    on_start: function () {
        document.body.style.cursor = "default";
    },
    show_clickable_nav: true,
    show_page_number: true,
    on_finish: function () {
        document.body.style.cursor = 'none'
    },
}
/*  Displays stimulus from timeline, checks if tgtDir matches correct keypress and sets data.correct
    pushes trial information to dataOut 
*/
var VDACtrial = {
    type: jsPsychPsychophysics,
    choices: [keys[0], keys[1]],
    trial_duration: 1000,      //TESTTESTTEST ORIGINAL 1000
    stimuli: jsPsych.timelineVariable('stimulus'),
    data: jsPsych.timelineVariable('data'),
    canvas_width: wd,
    canvas_height: ht,
    on_finish: function (data) {
        var correct = null;
        if (data.tgtDir == 'h' && jsPsych.pluginAPI.compareKeys(data.response, keys[0]) || data.tgtDir == 'v' && jsPsych.pluginAPI.compareKeys(data.response, keys[1])) {
            correct = true
        } else if (data.tgtDir == 'h' && jsPsych.pluginAPI.compareKeys(data.response, keys[1]) || data.tgtDir == 'v' && jsPsych.pluginAPI.compareKeys(data.response, keys[0])) {
            correct = false;
        }
        data.correct = correct;

        if (data.trialType == 'VDACtest') {
            dataOut.trialNum.push(trialNum)
            trialNum++
        } else {
            dataOut.trialNum.push(0)
        }

        if (data.rwdPos == data.tgtPos) {
            dataOut.rwdType.push(2)
            data.rwdType = 'high'
        } else {
            dataOut.rwdType.push(1)
            data.rwdType = 'low'
        }

        dataOut.subID.push(data.subject)
        dataOut.trialType.push(data.trialType)
        dataOut.cntBalance.push(data.condition)
        dataOut.correct.push(data.correct)
        dataOut.rt.push(data.rt)
        dataOut.rwdPos.push(data.rwdPos)
        dataOut.tgtPos.push(data.tgtPos)
        dataOut.tgtDir.push(data.tgtDir)

        dataOut.colPos.push('')
        dataOut.colMatch.push('')

    },
    post_trial_gap: 1000, //TESTTESTTEST ORIGINAL 1000
}

var rwdTotal = Math.round(0)
var fdbk = [
    '<p style="font-size:300%;">Correct!</p>',
    '<p style="font-size:300%;">Miss.</p> <p style="font-size:300%;">Wrong response.</p>',
    '<p style="font-size:300%;">Miss.</p> <p style="font-size:300%;">Too slow.</p>',
    '<p style="font-size:300%;">Miss.</p>'
]
var fdbkNoPts = {
    type: jsPsychHtmlKeyboardResponse,
    stimulus: function () {
        if (jsPsych.data.getLastTrialData().values()[0].correct == true) {
            return fdbk[0]
        } else if (jsPsych.data.getLastTrialData().values()[0].correct == false) {
            return fdbk[1]
        } else if (jsPsych.data.getLastTrialData().values()[0].correct == null) {
            return fdbk[2]
        }
    },
    choices: 'NO_KEYS',
    trial_duration: 1500,
    post_trial_gap: 1000,
}

/*Shows feedback according to data.correct and rwdType. Assigns rewardTrial to 2. If rwdType is 'low', there's an 20% chance rewardTrial will be 10.
If rwdType is 'high' 80% chance rewardTrial will be 10.
After correct or wrong response, adds a 0 to attCount and shifts the array.
After null response, adds a 1 to attCount and shifts the array.
*/
var fdbkPts = {
    type: jsPsychHtmlKeyboardResponse,
    stimulus: function (data) {
        var rewardTrial = 2
        if (jsPsych.data.getLastTrialData().values()[0].correct == true && jsPsych.data.getLastTrialData().values()[0].rwdType == 'low') {
            attCount.push(0)
            attCount.shift()
            if (Math.random() < .0) { //TESTTESTTEST
                rewardTrial = 10
            }
            rwdTotal = rwdTotal + rewardTrial
            return '<p style="font-size:300%;"> + ' + rewardTrial + ' points.</p><p style="font-size:300%">Total: ' + rwdTotal + ' points.</p>'
        } else if (jsPsych.data.getLastTrialData().values()[0].correct == true && jsPsych.data.getLastTrialData().values()[0].rwdType == 'high') {
            attCount.push(0)
            attCount.shift()
            if (Math.random() < 1) { //TESTTESTTEST
                rewardTrial = 10
            }
            rwdTotal = rwdTotal + rewardTrial
            return '<p style="font-size:300%;"> + ' + rewardTrial + ' points.</p><p style="font-size:300%">Total: ' + rwdTotal + ' points.</p>'
        } else if (jsPsych.data.getLastTrialData().values()[0].correct == false) {
            return fdbk[3] + '<p style="font-size:300%">Total: ' + rwdTotal + ' points.</p>'
        } else if (jsPsych.data.getLastTrialData().values()[0].correct == null) {
            attCount.push(1)
            attCount.shift()
            return fdbk[3] + '<p style="font-size:300%">Total: ' + rwdTotal + ' points.</p>'
        }
    },
    on_finish: function (data) {
        data.reward = rwdTotal
        brkCounter++
    },
    choices: 'NO_KEYS',
    trial_duration: 1500,   //TESTTESTTEST 1500
    post_trial_gap: 1000,   //TESTTESTTEST
}

var colArr = ['r', 'g', 'b']
var dirArr = ['h', 'v']
var trainArrVDAC = [
    { stimulus: drawVDACtrain(0, 0, dirArr[0]), data: { trialType: 'VDACtrain', rwdPos: 0, tgtPos: 0, tgtDir: dirArr[0] } },
    { stimulus: drawVDACtrain(1, 1, dirArr[0]), data: { trialType: 'VDACtrain', rwdPos: 1, tgtPos: 1, tgtDir: dirArr[0] } },
    { stimulus: drawVDACtrain(2, 2, dirArr[0]), data: { trialType: 'VDACtrain', rwdPos: 2, tgtPos: 2, tgtDir: dirArr[0] } },
    { stimulus: drawVDACtrain(3, 3, dirArr[0]), data: { trialType: 'VDACtrain', rwdPos: 3, tgtPos: 3, tgtDir: dirArr[0] } }
];

//Prompt to repeat trials, generates r or c for data.response
var repeatPrompt = {
    type: jsPsychHtmlKeyboardResponse,
    stimulus: '<p>You have now finished the training exercise. If you would like to repeat the instructions and training exercise, press <b>R</b>.' +
        '<p>If you are ready to continue to the task, press <b>C</b>.</p>',
    choices: ['r', 'c'],
}

//Countdown to start experiment. Timeline prompt starts in cntDwnArr. 1 second prompts with countdown are pushed into cntDwnArr 
var cntDwnArr = [
    {
        type: jsPsychHtmlKeyboardResponse,
        stimulus: '<p>Place your fingers on the <b>' + keys[0] + '</b> and <b>' + keys[1] + '</b> keys. ' +
            'The experiment will begin shortly.</p> <p></p>',
        trial_duration: 3000,
        choices: ['p']
    }
];
for (let i = 5; i > 0; i--) {
    cntDwnArr.push(
        {
            type: jsPsychHtmlKeyboardResponse,
            stimulus: '<p>Place your fingers on the <b>' + keys[0] + '</b> and <b>' + keys[1] + '</b> keys. ' +
                "</b>The experiment will begin shortly.</p><p>" + i + "</p>",
            trial_duration: 1000,
            choices: ['p']
        }
    )
}
var cntDwnTimer = {
    timeline: cntDwnArr
}

var attCount = [0, 0, 0, 0, 0]
var attCheck = {
    timeline: [
        {
            type: jsPsychHtmlKeyboardResponse,
            stimulus: "<p>You have failed to respond to 5 consecutive trials. Please press the G key if you are still there and working at the task.</p>",
            choices: ['g'],
            minimum_valid_rt: 500,
            post_trial_gap: 1000,
            on_finish: function () {
                attCount = [0, 0, 0, 0, 0]
                dataOut.subID.push('attCheck')
                dataOut.trialType.push('attCheck')
                dataOut.trialNum.push('attCheck')
                dataOut.cntBalance.push('attCheck')
                dataOut.correct.push('attCheck')
                dataOut.rt.push('attCheck')
                dataOut.rwdType.push('attCheck')
                dataOut.rwdPos.push('attCheck')
                dataOut.tgtDir.push('attCheck')
                dataOut.tgtPos.push('attCheck')
                dataOut.colPos.push('attCheck')
                dataOut.colMatch.push('attCheck')
            }
        }
    ],
    conditional_function: function () {
        if (attCount.reduce((a, b) => a + b, 0) == 5) { //TESTTESTTEST ORIGINAL 5
            return true
        } else {
            return false
        }
    },
}

var brkCounter = 0
var brkCounterEnd = 0
function restPeriod(countDwn) {
    return '<p>The experiment will resume in ' + countDwn + ' seconds. ' +
        '<p>Remember, press <b>' + keys[0] + '</b> if the line is horizontal or <b>' + keys[1] + '</b> if the line is vertical.'
}
var restArr = []
for (let i = 30; i > 0; i--) {
    restArr.push(
        {
            stimulus: restPeriod(i)
        }
    )
}

var brkVDACfdbk = {
    type: jsPsychHtmlKeyboardResponse,
    stimulus: function () {
        var trials = jsPsych.data.get().filter({ trialType: 'VDACtest' });
        var correct_trials = trials.filter({ correct: true });
        var accuracy = Math.round(correct_trials.count() / trials.count() * 100);
        var rt = Math.round(correct_trials.select('rt').mean());
        return '<p>You have finished block ' + brkCounterEnd + ' of 4.' +
            '<p>You responded correctly on ' + accuracy + '% of the trials which has earned you ' + rwdTotal + ' points.' +
            '<p>On the next screen, you will be given a 30 second break. Press the <b>g</b> key to start your break.'
    },
    trial_duration: 30000,
    on_finish: function () {
        dataOut.subID.push('brk')
        dataOut.trialType.push('brk')
        dataOut.trialNum.push('brk')
        dataOut.cntBalance.push('brk')
        dataOut.correct.push('brk')
        dataOut.rt.push('brk')
        dataOut.rwdType.push('brk')
        dataOut.rwdPos.push('brk')
        dataOut.tgtDir.push('brk')
        dataOut.tgtPos.push('brk')
        dataOut.colPos.push('brk')
        dataOut.colMatch.push('brk')
    }
}

var brkVDACcntDwn = {
    type: jsPsychHtmlKeyboardResponse,
    stimulus: jsPsych.timelineVariable('stimulus'),
    choices: ['p'],
    trial_duration: 1000,
    timeline: restArr,
    on_finish: function (data) {
        if (jsPsych.pluginAPI.compareKeys(data.response, 'p')) {
            jsPsych.endCurrentTimeline();
        }
    },
}

//Set brkCounter == X to the number of trials per block. Set brkCounterEnd < Y to the number of blocks per experiment.
var VDACbreak = {
    timeline: [
        brkVDACfdbk,
        brkVDACcntDwn,
        cntDwnTimer
    ],
    conditional_function: function () {
        if (brkCounter == 50 && brkCounterEnd < 3) { //TESTTESTTEST ORIGNINAL BRKCOUNTER == X
            brkCounterEnd++
            brkCounter = 0
            return true
        } else {
            return false
        }
    }
}

var testArrVDAC = [];
testArrVDAC.push(
    { stimulus: drawVDACtest(1, 1, 'v'), data: { trialType: 'VDACtest', tgtPos: 1, rwdPos: 1, tgtDir: 'v' } },
    { stimulus: drawVDACtest(1, 1, 'v'), data: { trialType: 'VDACtest', tgtPos: 1, rwdPos: 1, tgtDir: 'v' } },
    { stimulus: drawVDACtest(1, 1, 'v'), data: { trialType: 'VDACtest', tgtPos: 1, rwdPos: 1, tgtDir: 'v' } },
    { stimulus: drawVDACtest(1, 1, 'v'), data: { trialType: 'VDACtest', tgtPos: 1, rwdPos: 1, tgtDir: 'v' } },
    { stimulus: drawVDACtest(1, 1, 'v'), data: { trialType: 'VDACtest', tgtPos: 1, rwdPos: 1, tgtDir: 'v' } }
)


//VDAC task with no points feedback, repeats if repeatPrompt is 'r'
var VDACtraining = {
    timeline: [VDACinstructions, cntDwnTimer,
        {
            timeline: [fixation, VDACtrial, fdbkNoPts],
            timeline_variables:
                trainArrVDAC,
            randomize_order: false,
        },
        repeatPrompt,
    ],
    loop_function: function (data) {
        if (jsPsych.data.getLastTrialData().values()[0].response == 'r') {
            return true;
        } else {
            return false;
        }
    },
}

var VDACtask = {
    timeline: [fixation, VDACtrial, fdbkPts],
    timeline_variables: testArrVDAC,
    randomize_order: true,
}

var resetCounter = {
    type: 'call-function',
    func: function () {
        brkCounter = 0
        brkCounterEnd = 0
        attCheck = [0, 0, 0, 0, 0]
        trialNum = 1
    }
}