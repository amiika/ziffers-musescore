import QtQuick 2.9
import QtQuick.Controls 1.5
import QtQuick.Layouts 1.3
import QtQuick.Dialogs 1.2
import MuseScore 3.0
import FileIO 3.0


MuseScore {
  version: "0.2"
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

  RowLayout {  // Octave shift
    id: rowOctaveShiftLabel
    x :itemX1
    y :itemY1+itemDY*4
    Label {
      text: "Octave shift"
    }
  }

  RowLayout { // Octave shift
    id: rowOctaveShift
    x :itemX2
    y :itemY1+itemDY*4
    SpinBox {
      id: octaveShiftInput
      implicitWidth: 55
      decimals: 0
      minimumValue: -5
      maximumValue: 5
      value: 0
    }
  }

  RowLayout { // Use bars
    id: rowIncludeBars
    x :itemX2
    y :itemY1+itemDY*5
    CheckBox {
      id: includeBars
      checked: true
      text: qsTr("Include bars")
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
    width: 1000
    height: 500
    contentItem: RowLayout {
      TextArea {
        anchors.fill: parent
        id: textHolder
        text: ".."
      }
    }
    onAccepted: {
      exportDialog.visible = false
      Qt.quit()
    }
    function openResultDialog(message) {
      textHolder.text = message
      open()
    }
  }

  function repeatStr(s, n) {
    var result = "";
    while (n > 0) {
      n = n - 1;
      result = result + s;
    }
    return result;
  }

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

    for (var staff = 0; staff<=curScore.nstaves-1; staff++) {
      for (var voice = 0; voice < 4; voice++) {

        console.log("Staff: ", staff, " Track: ", (staff*4)+voice, " Voice: ", voice);

        var measure = curScore.firstMeasure;
        var measureCounter = 1;
        var firstInMeasure = true;
        var zline = "";
        var lastOctave = 0;
        var lastLength = "";
        var startRepeatCount = 0;
        var endRepeatCount = 0;
        var elementsInVoice = false;
        var firstLine = true;

        var cursor = curScore.newCursor();
        cursor.rewind(Cursor.SCORE_START);
        cursor.voice = voice;
        cursor.staffIdx = staff;

        while (measure) {

          var segment = measure.firstSegment;

          while (segment) {

            /* Increment cursor to segment position */
            while(cursor.segment && segment.tick>cursor.tick) {
              cursor.next();
            }

            var sType = getSegmentType(segment);
            console.log("S: ",sType);

            // TODO: ANNOTATIONS & TEMPO's?

            if (segment.annotations && segment.annotations.length) {
              for (var a in segment.annotations) {
                console.log("Annotation:", segment.annotations[a].type + ": " + segment.annotations[a].name);
              }
            }

            // REPEATS

            if(sType=="BeginBarLine") {
              if(!firstLine) {
                zline+="\\\n"
              } else {
                firstLine = false
              }
              zline += "| "
              firstInMeasure = true;
            } else if(sType=="StartRepeatBarLine") {
              zline += "[: "
              startRepeatCount+=1;
            } else if(sType=="EndBarLine") {

              // No EndRepeatBarLine type!? Get subtype from first voice.
              var b = segment.elementAt(0);
              if(b && b.subtypeName()=="end-repeat") {
                zline += ":] "
                endRepeatCount+=1;
                if(endRepeatCount>startRepeatCount) {
                  /* Interpret missing start repeats */
                  zline = "[: "+zline;
                  startRepeatCount+=1;
                }
              } else { // Normal EndBarLine
                zline += "| "
              }

            }

            var el = segment.elementAt((staff*4)+voice);

            if (el) {
              elementsInVoice = true;
              // console.log("Element ", el.type, ": ",el.name);

              // NOTE DURATIONS

              if (el.type == Element.REST || el.type == Element.CHORD) {
                var currentLength = lengths[el.duration.ticks]

                if (lastLength != currentLength || (includeBars.checked && firstInMeasure)) {
                  if(durationList.key == 0) zline += currentLength + " ";
                  if(durationList.key == 2) zline += parseFloat((el.duration.ticks / 1920).toFixed(4)) + " ";
                  lastLength = currentLength;
                  firstInMeasure = false;
                }
              }

              // NOTES

              if (el.type == Element.CHORD) {

                var notes = cursor.element ? cursor.element.notes : null;

                if (notes) {
                  for (var k = 0; k < notes.length; k++) {
                    var note = notes[k];

                    // TODO: TIES?

                    if(note.tieBack || note.tieForward) console.log("Tieback: " + (note.tieBack != null) + " Tieforward: " + (note.tieForward != null))

                    // TODO: NOTE ELEMENTS?
                    for (var notEl in note.elements) {
                      var noteElement = note.elements[notEl]
                      console.log("Note element: "+noteElement.type, ": ",noteElement.name);
                    }

                    // TODO: Notate key change?
                    var rootNote = roots[cursor.keySignature+7]+octaveShift;
                    var pitchShift = rootNote - 60;
                    var octave = parseInt((note.pitch - pitchShift) / 12) - 5;
                    var pc = parseInt(note.pitch - pitchShift) % 12;
                    var npc = "";
                    var octaveChars = ""

                    // OCTAVES

                    if (lastOctave != octave) {
                      if (octaveList.key==0) {
                        var octaveChars = ""
                        octaveChars = repeatStr((octave < lastOctave ? "_" : "^"), Math.abs(lastOctave - octave));
                        zline += octaveChars + " ";
                      } else if(octaveList.key==2) {
                        zline += "<" + octave + "> ";
                      }
                      lastOctave = octave;
                    }

                    if (notes.tpc >= 6 && notes.tpc <= 12 && flats[pc].length == 2) {
                      npc = flats[pc];
                    } else if (notes.tpc >= 20 && notes.tpc <= 26 && flats[pc].length == 2) {
                      npc = sharps[pc];
                    } else {
                      npc = sharps[pc];
                    }

                    console.log("PC: ",pc," NPC: ",npc," ROOT: ", rootNote);

                    // Repeated octaves
                    if(octaveList.key == 1 && octave!=0) zline += repeatStr((octave < 0 ? "_" : "^"), Math.abs(octave));

                    // Repeated durations
                    if(durationList.key == 1) zline += currentLength;

                    zline += (scaleList.key==0 ? npc : pc.toString().replace('10','T').replace('11','E'))

                  }
                  zline+=" "
                }

              } else if (el.type == Element.REST) {
                if(durationList.key == 1) zline += currentLength;
                zline += "r ";
              }

            }

            segment = segment.nextInMeasure;

          }

          measure = measure.nextMeasure;
          measureCounter++;
        }

        // Push parsed voices to lines
        if(elementsInVoice && zline.length>0) {
          lines.push(zline);
        }

      }
    }

    resultDialog.openResultDialog(lines.join("\n\n"));
  }

  onRun: {
    if (typeof curScore === 'undefined')
    Qt.quit();
  }

}
