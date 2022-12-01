import QtQuick 2.9
import QtQuick.Controls 1.5
import QtQuick.Layouts 1.3
import QtQuick.Dialogs 1.2
import MuseScore 3.0
import FileIO 3.0

MuseScore {
  version: "0.4"
  description: qsTr("Export ziffers")
  menuPath: "Plugins.Ziffers"
  pluginType: "dialog"
  id: window
  width:285
  height:285
  property var itemX1 : 10
  property var itemX2 : 150
  property var itemY1 : 10
  property var itemDY : 25

  RowLayout {  // Duration type label
    id: durationLabel
    x: itemX1
    y: itemY1+itemDY*2
    Label {
      text: "Duration type"
    }
  }

  RowLayout { // DurationType
    id: rowDurationType
    x: itemX2
    y :itemY1+itemDY*2
    ComboBox {
      currentIndex: 0
      model: ListModel {
        id: durationList
        property var key
        ListElement { text: "Sequential"; dName: 0 }
        ListElement { text: "Repeated"; dName: 1 }
        ListElement { text: "Numeric"; dName: 2 }
        ListElement { text: "No durations"; dName: 3 }
      }
      width: 100
      onCurrentIndexChanged: {
        durationList.key = durationList.get(currentIndex).dName
      }
    }
  }

  RowLayout {  // OctaveType label
    id: rowOctaveLabel
    x :itemX1
    y :itemY1+itemDY*1
    Label {
      text: "Octave type"
    }
  }

  RowLayout { // OctaveType
    id: rowOctaveType
    x :itemX2
    y :itemY1+itemDY*1
    ComboBox {
      currentIndex: 0
      model: ListModel {
        id: octaveList
        property var key
        ListElement { text: "Additive"; oName: 0 }
        ListElement { text: "Repeated"; oName: 1 }
        ListElement { text: "Numeric"; oName: 2 }
        ListElement { text: "No octaves"; oName: 3 }
      }
      width: 100
      onCurrentIndexChanged: {
        octaveList.key = octaveList.get(currentIndex).oName
      }
    }
  }

  RowLayout {  // Scale label
    id: rowScaleLabel
    x :itemX1
    y :itemY1+itemDY*3
    Label {
      text: "Scale type"
    }
  }

  RowLayout { // ScaleType
    id: rowScaleType
    x :itemX2
    y :itemY1+itemDY*3
    ComboBox {
      currentIndex: 0
      model: ListModel {
        id: scaleList
        property var key
        ListElement { text: "Major/Minor"; sName: 0 }
        ListElement { text: "Chromatic"; sName: 1 }
      }
      width: 100
      onCurrentIndexChanged: {
        scaleList.key = scaleList.get(currentIndex).sName
      }
    }
  }

  RowLayout {  // Output label
    id: outputLabel
    x :itemX1
    y :itemY1+itemDY*4
    Label {
      text: "Output type"
    }
  }

  RowLayout { // Output type
    id: outputTypeMenu
    x :itemX2
    y :itemY1+itemDY*4
    ComboBox {
      currentIndex: 0
      model: ListModel {
        id: outputType
        property var key
        ListElement { text: "With bars"; oName: 0 }
        ListElement { text: "Without bars"; oName: 1 }
        ListElement { text: "Array with lines"; oName: 2 }
        ListElement { text: "Array without lines"; oName: 3 }
        ListElement { text: "Tracker array"; oName: 4 }
        ListElement { text: "Tracker text"; oName: 5 }
        ListElement { text: "Midi array"; oName: 6 }
      }
      width: 100
      onCurrentIndexChanged: {
        outputType.key = outputType.get(currentIndex).oName
      }
    }
  }

  RowLayout {  // Octave shift
    id: rowOctaveShiftLabel
    x :itemX1
    y :itemY1+itemDY*5
    Label {
      text: "Octave shift"
    }
  }

  RowLayout { // Octave shift
    id: rowOctaveShift
    x :itemX2
    y :itemY1+itemDY*5
    SpinBox {
      id: octaveShiftInput
      implicitWidth: 55
      decimals: 0
      minimumValue: -5
      maximumValue: 5
      value: 0
    }
  }

  RowLayout { // Use repeats
  id: rowIncludeRepeats
  x :itemX2
  y :itemY1+itemDY*6
  CheckBox {
  id: includeRepeats
  checked: true
  text: qsTr("Include repeats")
}
}


RowLayout {  // Quit / Run
  id: rowCancelOk
  x : 110
  y : 250
  Button {
    id: closeButton
    text: "Quit"
    onClicked: {
      Qt.quit()
    }
  }
  Button {
    id: okButton
    text: "Run"
    onClicked: {
      writeZiffers();
    }
  }
}

Dialog {
  id: resultDialog
  width: 1025
  height: 560

  // Removed contentItem: which should add default "OK" button.
  GridLayout {
    id: grid
    rows: 2
    width: 1000
    height: 500
    TextArea {
      anchors.fill: parent
      id: textHolder
      text: ".."
    }

  }
  function openResultDialog(message) {
    textHolder.text = message
    open()
  }
}
/* Some ES5 helpers */

property var _typeof:  function(obj) { "@babel/helpers - typeof"; return _typeof = "function" == typeof Symbol && "symbol" == typeof Symbol.iterator ? function (obj) { return typeof obj; } : function (obj) { return obj && "function" == typeof Symbol && obj.constructor === Symbol && obj !== Symbol.prototype ? "symbol" : typeof obj; }, _typeof(obj); }

property var isPrimitive: function isPrimitive(obj) {
  var arr = ["string", "number", "boolean"];
  return obj === null || arr.indexOf(_typeof(obj)) >= 0;
};

property  var isArrayOfPrimitive: function isArrayOfPrimitive(obj) {
  return Array.isArray(obj) && obj.every(isPrimitive);
};

property var format: function format(arr) {
  return "^^^[ ".concat(arr.map(function (val) {
    return JSON.stringify(val);
  }).join(', '), " ]");
};

property var replacer: function replacer(key, value) {
  return isArrayOfPrimitive(value) ? format(value) : value;
};

property var expand: function expand(str) {
  return str.replace(/(?:"\^\^\^)(\[ .* \])(?:\")/g, function (match, a) {
    return a.replace(/\\"/g, '"');
  });
};

function transpose(matrix) {
  const rows = matrix.length;
  const cols = matrix[0].length;
  const grid = [];
  for (var j = 0; j < cols; j++) {
    grid[j] = Array(rows);
  }
  for (var i = 0; i < rows; i++) {
    for (var j = 0; j < cols; j++) {
      grid[j][i] = matrix[i][j];
    }
  }
  return grid;
}

property var stringify: function stringify(obj) {
  return expand(JSON.stringify(obj, replacer, 2));
};

function repeatStr(s, n) {
  var result = "";
  while (n > 0) {
    n = n - 1;
    result = result + s;
  }
  return result;
}

/* Helper constants */

property var sharps: ["0", "#0", "1", "#1", "2", "3", "#3", "4", "#4", "5", "#5", "6"];

property var flats: ["0", "b1", "1", "b2", "2", "3", "b4", "4", "b5", "5", "b6", "6"];

//  KeySig   -7  -6  -5  -4  -3  -2  -1   0   1   2   3   4   5   6   7
property var roots: [71, 66, 61, 68, 63, 70, 65, 60, 67, 62, 69, 64, 71, 66, 61];

property var lengths: Object.freeze({
  3840: "d",
  2880: "w.",
  2560: 'c',
  1920: "w",
  1680: "h..",
  1440: "h.",
  1280: "y",
  960: "h",
  840: "q..",
  720: "q.",
  640: "n",
  480: "q",
  420: "e..",
  360: "e.",
  320: "a",
  240: "e",
  210: "s..",
  180: "s.",
  160: "f",
  120: "s",
  105: "t..",
  90: "t.",
  80: "x",
  60: "t",
  45: "u.",
  40: "g",
  30: "u",
});

property var segmentTypes: Object.freeze({
  0: "Invalid",
  1: "BeginBarLine",
  2: "HeaderClef",
  4: "KeySig",
  8: "Ambitus",
  16: "TimeSig",
  32: "StartRepeatBarLine",
  64: "Clef",
  128: "BarLine",
  256: "Breath",
  512: "ChordRest",
  1024: "EndBarLine",
  2048: "KeySigAnnounce",
  4096: "TimeSigAnnounce"
});

function getSegmentType(s) {
  return segmentTypes[Number(s.segmentType)]
}

function writeZiffers() {
  var lines = []

  var octaveShift = 12*octaveShiftInput.value;
  var scoreStaffs = [];
      
  var cursor = curScore.newCursor();
  var endTick = 0;  
  var fullScore = false;
  var startStaff = 0;
  var endStaff = curScore.nstaves - 1;
   
  cursor.rewind(1);  // rewind to start of selection
   if (!cursor.segment) { // no selection
     fullScore = true;
   } else {
    startStaff = cursor.staffIdx;
    cursor.rewind(2); // rewind to end of selection
    endTick = cursor.tick;
    endStaff   = cursor.staffIdx;
   }

  for (var staff = startStaff; staff<=endStaff; staff++) {
    var staffVoices = [];
    for (var voice = 0; voice < 4; voice++) {

      console.log("Staff: ", staff, " Track: ", (staff*4)+voice, " Voice: ", voice);

      var measureCounter = 1;
      var voiceRows = [];
      var rowMeasures = [];
      var firstInMeasure = true;
      var measureArray = [];
      var measureString = "";
      var lastOctave = 0;
      var lastLength = "";
      var startRepeatCount = 0;
      var endRepeatCount = 0;
      var elementsInVoice = false;
      var firstLine = true;

      if(fullScore) {
        cursor.rewind(Cursor.SCORE_START);
      } else {
        cursor.rewind(1);
      }
      cursor.voice = voice;
      cursor.staffIdx = staff;

      var measure = fullScore ? curScore.firstMeasure : cursor.measure
      
      while ((measure && fullScore) || (measure && cursor.tick<endTick)) {

        var segment = measure.firstSegment;

        while (segment) {

          /* Increment cursor to segment position */
          while(cursor.segment && segment.tick>cursor.tick) {
            cursor.next();
          }

          var sType = getSegmentType(segment);
          //console.log("S: ",sType);

          // TODO: ANNOTATIONS & TEMPO's?

          if (segment.annotations && segment.annotations.length) {
            for (var a in segment.annotations) {
              //  console.log("Annotation:", segment.annotations[a].type + ": " + segment.annotations[a].name);
            }
          }

          // BARS & REPEATS

          if(sType=="BeginBarLine") {
            if(!firstLine) { // Skips first line
              if(rowMeasures.length>0) {
                if(outputType.key == 0) rowMeasures = rowMeasures.join(" | ");
                if(outputType.key == 1) rowMeasures = rowMeasures.join(" ");
                voiceRows.push(rowMeasures);
                rowMeasures = [];
              }
            } else {
              firstLine = false
            }
            firstInMeasure = true;
          } else if(sType=="StartRepeatBarLine") {
            if(includeRepeats.checked && !(outputType.key == 4 || outputType.key == 5)) measureString += "[: "
            startRepeatCount+=1;
          } else if(sType=="EndBarLine") {
            firstInMeasure = true;
            // No EndRepeatBarLine type!? Get subtype from first voice.
            var b = segment.elementAt(0);
            if(b && b.subtypeName()=="end-repeat") {
              if(includeRepeats.checked  && !(outputType.key == 4 || outputType.key == 5)) measureString += ":] "
              endRepeatCount+=1;
            } else { // Normal EndBarLine
            }

          }

          var el = segment.elementAt((staff*4)+voice);

          if (el) {
            elementsInVoice = true;
            //console.log("Measure: ",measureCounter, " Element: ", el.type, ": ",el.name);

            // NOTE DURATIONS

            if (el.type == Element.REST || el.type == Element.CHORD) {

              var currentLength = lengths[el.duration.ticks]
			
              if (durationList.key!=3 && (lastLength!=currentLength || (outputType.key!=1 && firstInMeasure))) {
                if(durationList.key == 0 && currentLength!=undefined) measureString += currentLength + " ";
                if(durationList.key == 2 || currentLength==undefined) measureString += parseFloat((el.duration.ticks / 1920).toFixed(4)) + " ";
                lastLength = currentLength;

              }

            }

            // NOTES

            if (el.type == Element.CHORD) {
              var notes = cursor.element ? cursor.element.notes : null;

              if (notes) {
                var chordArray = [];

                for (var k = 0; k < notes.length; k++) {
                  var note = notes[k];

                  if(note.tieBack || note.tieForward) {
                    //  console.log("Tieback: " + (note.tieBack != null) + " Tieforward: " + (note.tieForward != null))
                  }

                  // TODO: NOTE ELEMENTS?
                  for (var notEl in note.elements) {
                    var noteElement = note.elements[notEl]
                    //console.log("Note element: "+noteElement.type, ": ",noteElement.name);
                  }

                  // TODO: Notate key change?
                  var rootNote = roots[cursor.keySignature+7]+octaveShift;
                  var pitchShift = rootNote - 60;
                  var octave = parseInt((note.pitch - pitchShift) / 12) - 5;
                  var pc = parseInt(note.pitch - pitchShift) % 12;
                  var npc = "";
                  var octaveChars = "";

                  // OCTAVES

                  if (octaveList.key!=3 && (lastOctave != octave)) {
                    if (octaveList.key==0) { // Octave symbol
                        var octaveChars = "";
                        octaveChars = repeatStr((octave < lastOctave ? "_" : "^"), Math.abs(lastOctave - octave));
                        measureString += octaveChars + (notes.length>1 ? "" : " ");
                    } else if(octaveList.key==2) { // Octave number
                      measureString += "<" + octave + ">" + (notes.length>1 ? "" : " ");
                    }
                    if(notes.length<2) lastOctave = octave;
                  }

                  firstInMeasure = false; // Used to print note length & octave in the beginning of measure

                  if (notes.tpc >= 6 && notes.tpc <= 12 && flats[pc].length == 2) {
                    npc = flats[pc];
                  } else if (notes.tpc >= 20 && notes.tpc <= 26 && flats[pc].length == 2) {
                    npc = sharps[pc];
                  } else {
                    npc = sharps[pc];
                  }

                  //  console.log("PC: ",pc," NPC: ",npc," ROOT: ", rootNote);

                  // Repeated octaves
                  if(octaveList.key == 1 && octave!=0) measureString += repeatStr((octave < 0 ? "_" : "^"), Math.abs(octave));

                  // Repeated durations
                  if(durationList.key == 1) measureString += currentLength;

                  var noteArray = [parseFloat((el.duration.ticks / 1920).toFixed(4)),note.pitch];

                  if(notes.length>1) {
                    chordArray.push(noteArray);
                  } else {
                    measureArray.push(noteArray);
                  }

                  measureString += (scaleList.key==0 ? npc : pc.toString().replace('10','T').replace('11','E'))

                }

                if(notes.length>1) {
                  measureArray.push(chordArray);
                  chordArray = [];
                }
                measureString+=" "
              }

            } else if (el.type == Element.REST) {
              if(durationList.key == 1) measureString += currentLength;

              measureArray.push([parseFloat((el.duration.ticks / 1920).toFixed(4)),"r"]);

              measureString += "r ";
            }

          }

          segment = segment.nextInMeasure;

        }

        if(measureString.length>0) {
          if(outputType.key==6) {
            rowMeasures.push(measureArray);
          } else {
            rowMeasures.push(measureString);
          }
          measureString = "";
          measureArray = [];
        }

        measure = measure.nextMeasure;
        measureCounter++;

        if(!(outputType.key == 1 && octaveList.key == 0)) {
          // Reset octave unless output is one big measure
          lastOctave = 0
        }

      }

      if(rowMeasures.length>0) { // Push last row
        if(outputType.key == 0) rowMeasures = rowMeasures.join(" | ")+" |";
        if(outputType.key == 1) rowMeasures = rowMeasures.join(" ");
        voiceRows.push(rowMeasures);
      }

      if(elementsInVoice && voiceRows.length>0) {
        if(outputType.key == 0) voiceRows = voiceRows.join("| \\\n| ");
        if(outputType.key == 1) voiceRows = voiceRows.join(" ");
        if(outputType.key == 3 || outputType.key == 4 || outputType.key == 5) voiceRows = voiceRows.concat.apply([], voiceRows);
        if(includeRepeats.checked  && !(outputType.key == 4 || outputType.key == 5) && endRepeatCount>startRepeatCount) {
          if (outputType.key == 0 || outputType.key == 1) {
            voiceRows = (outputType.key == 0 ? "|" : "")+repeatStr("[:",endRepeatCount-startRepeatCount)+" "+voiceRows
          } else {
            voiceRows[0] = repeatStr("[:",endRepeatCount-startRepeatCount)+" "+voiceRows[0]
          }
        } else {
          if(outputType.key == 0) voiceRows = "| "+voiceRows
        }
        staffVoices.push(voiceRows);
        voiceRows = [];
      }
    }
    if(outputType.key == 0 || outputType.key == 1) staffVoices = staffVoices.join(" \n\n");
    scoreStaffs.push(staffVoices);
    staffVoices = [];
  }

  var resultString = "No output!"

  if(outputType.key == 4 || outputType.key == 5)  {
    scoreStaffs = scoreStaffs.concat.apply([], scoreStaffs)
    scoreStaffs = transpose(scoreStaffs)
  }

  if(outputType.key == 0 || outputType.key == 1) {
    resultString =scoreStaffs.join("\n\n");
  } else if(outputType.key == 5) {
    scoreStaffs = scoreStaffs.map(function(e){
      return e.join(" | ");
    });
    resultString = scoreStaffs.join("\n");
  } else {

    resultString = outputType.key==6 ? JSON.stringify(scoreStaffs) : stringify(scoreStaffs);

  }
  resultDialog.openResultDialog(resultString);
}

onRun: {
  if (typeof curScore === 'undefined')
  Qt.quit();
}

}
