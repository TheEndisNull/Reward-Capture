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

function drawVDACstim(tgtPos, tgtCol, tgtDir) {
    var x = [.26 * ht, .0 * ht, -.26 * ht, -.26 * ht, .0 * ht, .26 * ht]
    var y = [.15 * ht, .30 * ht, .15 * ht, -.15 * ht, -.30 * ht, -.15 * ht]
    var r = [.1 * ht, .09 * ht]

    var colArr = jsPsych.randomization.shuffle(['yan', 'blue', 'black', 'magenta', 'yellow']);
    if (tgtCol == 'r') {
        colArr.splice(tgtPos, 0, 'red')
    } else if (tgtCol == 'g') {
        colArr.splice(tgtPos, 0, 'lime')
    }

    var angle = [];
    for (let i = 0; i < 5; i++) {
        if (Math.random() < 0.5) {
            angle.push(45)
        } else {
            angle.push(-45)
        }
    }

    if (tgtDir == 'h') {
        angle.splice(tgtPos, 0, '90')
    } else if (tgtDir == 'v') {
        angle.splice(tgtPos, 0, '0')
    }

    var VDACstim = []
    VDACstim = VDACstim.concat(fixationStim);
    for (i = 0; i < 6; i++) {
        VDACstim.push({
            obj_type: 'circle',
            startX: x[i], // location in the canvas
            startY: y[i],
            radius: r[0],
            line_color: colArr[i],
            fill_color: 'grey',
            line_width: 7,
            origin_center: true,
        }, {
            obj_type: 'line',
            startX: x[i], // location in the canvas
            startY: y[i],
            line_length: 50,
            line_width: 5,
            angle: angle[i],
            line_color: 'black',
            origin_center: true,
        }
        )
    }
    return VDACstim
}

function drawVDACtrain(tgtPos, tgtCol, tgtDir) {
    var VDACstim = drawVDACstim(tgtPos, tgtCol, tgtDir)
    VDACstim.push({
        obj_type: 'text',
        startX: 'center',
        startY: .95 * ht,
        content: 'Press ' + keys[0] + ' for horizontal or ' + keys[1] + ' for vertical',
        show_end_time: 2000 // disappear this text
    })
    return VDACstim
}

var attCount = [0, 0, 0, 0, 0]
var attCheck = {
    timeline: [
        {
            type: "html-keyboard-response",
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
                dataOut.tgtCol.push('attCheck')
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
