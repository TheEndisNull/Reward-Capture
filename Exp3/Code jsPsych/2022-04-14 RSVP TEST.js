//COUNTERS & BREAKS

var brkRSVPfdbk = {
    type: jsPsychHtmlKeyboardResponse,
    stimulus: function () {
        var trials = jsPsych.data.get().filter({ trialType: 'RSVPtest' });
        var correct_trials = trials.filter({ correct: true });
        var accuracy = Math.round(correct_trials.count() / trials.count() * 100);
        var rt = Math.round(correct_trials.select('rt').mean());
        return '<p>You have finished block ' + brkCounterEnd + ' of 4.' +
            '<p>You responded correctly on ' + accuracy + '% of the trials.' +
            '<p>On the next screen, you will be given a 30 second break. Press the <b>g</b> key to start your break.'
    },
    choices: ['g'],
    trial_duration: 30000,
    on_finish: function () {
        dataOut.subID.push('brk')
        dataOut.trialType.push('brk')
        dataOut.trialNum.push('brk')
        dataOut.cntBalance.push('brk')
        dataOut.correct.push('brk')
        dataOut.rt.push('brk')
        dataOut.rwdType.push('brk')
        dataOut.tgtCol.push('brk')
        dataOut.tgtDir.push('brk')
        dataOut.tgtPos.push('brk')
        dataOut.colPos.push('brk')
        dataOut.colMatch.push('brk')
    }
}

var brkRSVPcntDwn = {
    type: jsPsychHtmlKeyboardResponse,
    stimulus: jsPsych.timelineVariable('stimulus'),
    choices: ['p'],
    trial_duration: 1000,
    timeline: restArrRSVP,
    on_finish: function (data) {
        if (jsPsych.pluginAPI.compareKeys(data.response, 'p')) {
            jsPsych.endCurrentTimeline();
        }
    },
}

//Set brkCounter == X to the number of trials per block. Set brkCounterEnd < Y to the number of blocks per experiment.
var RSVPbreak = {
    timeline: [
        brkRSVPfdbk,
        brkRSVPcntDwn,
        cntDwnTimer
    ],
    conditional_function: function () {
        if (brkCounter == 60 && brkCounterEnd < 3) {    ////////////////////CHANGED FOR TESTING//////////////////
            brkCounter = 0
            brkCounterEnd++
            return true
        } else {
            return false
        }
    }
}

//TRIAL STIMULI
//Array of letters, the first half correspond to BACS1, the second correspond to BACS2
var letters = [
    'q', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', 'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', 'z', 'c', 'v', 'b', 'n', 'm', //24
    'Q', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P', 'A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L', 'Z', 'C', 'V', 'B', 'N', 'M', //24

    'q', 'w', 'e', 'r', 't', 'y', 'u', 'o', 'p', 'a', 'd', 'f', 'g', 'h', 'l', 'x', 'b', 'n', 'm', //19
    'Q', 'E', 'T', 'Y', 'U', 'I', 'P', 'A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L', 'Z', 'X', 'C', 'V', 'B', 'N', 'M' //23
]
//select random number indicating which letter will be used. Then determine if that number corresponds to a bacs1 or bacs2 letter (i.e., if number is < 24, then bacs 1, else bacs2)
function pickFont(font) {
    if (font < 48) {
        return "200px 'BACS1'"
    } else {
        return "200px 'BACS2'"
    }
}

function drawMemStim(dir, color, colPos, tgt) {
    var arr = [...Array(90).keys()]
    arr = jsPsych.randomization.repeat(arr, 1);
    arr = arr.splice(0, 5)
    console.log(arr)
    var colArr = ['black', 'black']
    if (color == 'r') {
        colArr.splice(colPos, 0, 'white')
    } else if (color == 'g') {
        colArr.splice(colPos, 0, 'white')
    } else {
        colArr.splice(colPos, 0, 'white')
    }

    if (dir == 0) {
        x = [.0 * ht, .15 * ht, 0 * ht, -.15 * ht]
        y = [-.15 * ht, .0 * ht, .15 * ht, 0 * ht]
    } else if (dir == 1) {
        x = [.0 * ht, .15 * ht, 0 * ht, -.15 * ht]
        y = [-.15 * ht, .0 * ht, .15 * ht, 0 * ht]
    }

    var arrMemStim = [{
        obj_type: 'line',
        startX: 0,
        startY: 0,
        line_length: 50,
        angle: 0,
        line_width: 5,
        line_color: 'black',
        show_end_time: 2000,
        origin_center: true,
    }, {
        obj_type: 'line',
        startX: 0,
        startY: 0,
        line_length: 50,
        angle: 90,
        line_width: 5,
        line_color: 'black',
        show_end_time: 2000,
        origin_center: true,
    }, {
        obj_type: 'text',
        content: letters[arr[tgt]],
        font: pickFont(arr[tgt]),
        show_start_time: 2000,
        show_end_time: 5000,
        origin_center: true,
    }]

    //Draw mask

    const mask = {
        obj_type: 'text',
        content: 'X',
        font: "200px 'Arial'",
        startX: x[i], // location in the canvas
        startY: y[i],
        show_start_time: 1000,
        show_end_time: 12500,
        origin_center: true,
    }

    for (i = 0; i < 4; i++) {
        arrMemStim.push({
            obj_type: 'text',
            content: letters[arr[i]],
            startX: x[i], // location in the canvas
            startY: y[i] + .3*ht,
            font: pickFont(arr[i]),
            text_color: colArr[i],
            show_end_time: 750,
            origin_center: true,
        }, {
            ...mask,
            startX: x[i], // location in the canvas
            startY: y[i],
        }, { 
            ...mask,
            startX: x[i] + .07*ht, // location in the canvas
            startY: y[i],
        }, { 
            ...mask,
            startX: x[i] - .07*ht, // location in the canvas
            startY: y[i],
        }
        )
    }
    return arrMemStim
}

function drawMemStimTrain(dir, color, colPos, tgt) {
    var arrRSVPstim = drawMemStim(dir, color, colPos, tgt)
    arrRSVPstim.push({
        obj_type: 'text',
        startX: 'center',
        startY: .95 * ht,
        content: 'Press ' + keys[0] + ' for same or ' + keys[1] + ' for different',
        show_start_time: 2000,
        show_end_time: 5000,
    })
}

//EXPERIMENT PROCEDURE
var RSVPinstructions = {
    type: jsPsychInstructions,
    pages: [
        '<div style= "font-size:20px;" <p> <strong> Welcome to the experiment! </strong><br> <p style="color:red; font-size:25px;"> Please do NOT exit full screen until you are done with the experiment. </p>' +
        '<p style="color:red;"> The experiment will be canceled and your data will be lost if you try to go back or refresh the page at any time during the experiment.</p>' +
        '<p style="color:red;"> Please rely on your memory and do NOT write anything down throughout the experiment. </p>' +
        '<br>' +
        '<p style="color:black;">Click next or use the arrow keys to proceed.</p> </span>'
        ,
        'In this task, your job is to detect either a horizontal line or a vertical line among five other diagonal lines.  Each trial will begin with a + symbol in the center of the screen. You should focus your eyes on that + symbol. Then six differently colored circles will appear. Each one will have a line inside of them.' +
        '<p>Your target—the horizontal or vertical line—will always be inside a red or green circle. You should press <b>' + keys[0] + '</b> if the line is horizontal or <b>' + keys[1] + '</b> if the line is vertical. You will see examples on the following pages.' +
        '<p>Click next or use the arrow keys to proceed.</p>'
        ,
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

var RSVPtest = {
    type: jsPsychPsychophysics,
    choices: [keys[0], keys[1]],
    trial_duration: 50000,      //TESTTESTTEST ORIGINAL 1000
    stimuli: jsPsych.timelineVariable('stimulus'),
    data: jsPsych.timelineVariable('data'),
    post_trial_gap: 1000,
    canvas_width: wd,
    canvas_height: ht,
    post_trial_gap: 1000, //TESTTESTTEST ORIGINAL 1000
    on_finish: function (data) {
        var correct = null;
        if (data.tgtPos != 3 && data.response == keys[0] || data.tgtPos == 3 && data.response == keys[1]) {
            correct = true
        } else if (data.tgtPos != 3 && data.response == keys[1] || data.tgtPos == 3 && data.response == keys[0]) {
            correct = false
        }
        data.correct = correct

        dataOut.subID.push(data.subject)
        dataOut.trialType.push(data.trialType)
        if (data.trialType == 'RSVPtest') {
            dataOut.trialNum.push(trialNum)
            trialNum++
        } else {
            dataOut.trialNum.push(0)
        }
        dataOut.cntBalance.push(data.condition)
        dataOut.correct.push(data.correct)
        dataOut.rt.push(data.rt)
        if (data.tgtCol == cntBalance[0]) {
            dataOut.rwdType.push(2)
        } else if (data.tgtCol != cntBalance[0] & data.tgtCol != 'b') {
            dataOut.rwdType.push(1)
        } else {
            dataOut.rwdType.push(0)
        }
        //dataOut.tgtCol.push(data.tgtCol)
        dataOut.tgtPos.push(data.tgtPos)
        dataOut.colPos.push(data.colPos)
        if (data.tgtPos == data.colPos & data.tgtCol != 'b') {
            dataOut.colMatch.push(2)
        } else if (data.tgtPos != data.colPos & data.tgtCol != 'b') {
            dataOut.colMatch.push(1)
        } else {
            dataOut.colMatch.push(0)
        }

        dataOut.tgtDir.push('')

    }
}

//dir, color, colPos, tgt
//timeline variable for training array
var testArrMem = []
//repeat r times
for (r = 0; r < 3; r++) {
    //direction d=0 and d=1                               
    for (let d = 0; d < 2; d++) {
        //color cp at 0, 1, and 2
        for (let cp = 0; cp < 3; cp++) {
            //color c at 0 and 1 for r and g
            for (let c = 0; c < 2; c++) {
                //target position t at 0, 1, 2
                for (let t = 0; t < 3; t++) {
                    testArrMem.push(
                        {
                            stimulus: drawMemStim(d, colArr[c], cp, t),
                            data: {
                                trialType: 'RSVPtest',
                                tgtCol: colArr[c],
                                colPos: cp,
                                tgtPos: t
                            }
                        }
                    )
                }
                //target position 3 at a 2:3 ratio compared to color
                for (let mn = 0; mn < 2; mn++) {       //col r and g
                    testArrMem.push(
                        {
                            stimulus: drawMemStim(d, colArr[c], cp, 3),
                            data: {
                                trialType: 'RSVPtest',
                                tgtCol: colArr[c],
                                colPos: cp,
                                tgtPos: 3
                            }
                        }
                    )
                }
            }
        }
        for (let t = 0; t < 3; t++) {
            for (let m = 0; m < 2; m++) {
                testArrMem.push(
                    {
                        stimulus: drawMemStim(d, 'b', 3, t),
                        data: {
                            trialType: 'RSVPtest',
                            tgtCol: 'b',
                            colPos: 3,
                            tgtPos: t
                        }
                    }
                )
            }
        }
        for (let nm = 0; nm < 4; nm++) {
            testArrMem.push(
                {
                    stimulus: drawMemStim(d, 'b', 3, 3),    //(direction, [r,g,b], [0,1,2,3])
                    data: {
                        trialType: 'RSVPtest',                          //RSVPtest
                        tgtCol: 'b',                                     //[r,g,b]
                        colPos: 3,                                      //[0,1,2,3]
                        tgtPos: 3                                       //[0,1,2,3]
                    }
                }
            )
        }
    }
}

var trainArrMem = []

var RSVPexercise = {
    timeline: [fixation, RSVPtest, fdbkNoPts],
    timeline_variables: trainArrMem,
    randomize_order: true,
}

var RSVPtraining = {
    timeline: [RSVPexercise, repeatPrompt],
    loop_function: function (data) {
        if (jsPsych.data.getLastTrialData().values()[0].response == 'r') {
            return true;
        } else {
            return false;
        }
    },
}

var RSVPfeedback = {
    type: jsPsychHtmlKeyboardResponse,
    stimulus: function () {
        if (jsPsych.data.getLastTrialData().values()[0].correct == true) {
            attCount.push(0)
            attCount.shift()
            return fdbk[0]
        } else if (jsPsych.data.getLastTrialData().values()[0].correct == false) {
            attCount.push(0)
            attCount.shift()
            return fdbk[3]
        } else if (jsPsych.data.getLastTrialData().values()[0].correct == null) {
            attCount.push(1)
            attCount.shift()
            return fdbk[2]
        }
    },
    on_finish: function (data) {
        brkCounter++
    },
    choices: 'NO_KEYS',
    trial_duration: 1500,   //TESTTESTTEST 1500
    post_trial_gap: 1000,   //TESTTESTTEST 1000
}

function restPeriodRSVP(countDwn) {
    return '<p>The experiment will resume in ' + countDwn + ' seconds. ' +
        '<p> Remember, press <b>' + keys[0] + '</b> if the symbol is old or <b>' + keys[1] + '</b> if the symbol is new.'
}
var restArrRSVP = []
for (let i = 30; i > 0; i--) {
    restArrRSVP.push(
        {
            stimulus: restPeriodRSVP(i)
        }
    )
}

var RSVPtask = {
    timeline: [fixation, RSVPtest, RSVPfeedback, attCheck, RSVPbreak],
    timeline_variables: testArrMem,
    randomize_order: true,

}