import QtQuick 2.9
import QtQuick.Controls 1.5
import QtQuick.Layouts 1.3
import QtQuick.Dialogs 1.2
import MuseScore 3.0
import FileIO 3.0


MuseScore {
    version: "0.1"
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
  
    // output file to save the notes
    //FileIO {
    //    id: outfile
    //    source: "C:/Users/miika.alonen/Documents/test.txt" // to be changed according your configuration
    //    onError: console.log(msg)
    //}

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

    function writeZiffers() {
        var octaveType = 1 // By default 1 means additive ^ and _
        var noteLengthType = 1 // By default 1 means separate note length characters
            
        var sharps = ["0", "#0", "1", "#1", "2", "3", "#3", "4", "#4", "5", "#5", "6"];
        var flats = ["0", "b1", "1", "b2", "2", "3", "b4", "4", "b5", "5", "b6", "6"];
		//           -7  -6  -5  -4  -3  -2  -1   0   1   2   3   4   5   6   7
		var roots = [71, 66, 61, 68, 63, 70, 65, 60, 67, 62, 69, 64, 71, 66, 61];
        var lengths = {
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

        };
        var cursor = curScore.newCursor();
		
		var startStaff = 0;
        var endStaff = curScore.nstaves - 1;
		var endTick;
		var fullScore = false;
		
		var octaveShift = 12*octaveShiftInput.value;
		
		cursor.rewind(Cursor.SELECTION_START);
		if (!cursor.segment) { // no selection
		  fullScore = true;
		} else {
		  startStaff = cursor.staffIdx;
		  cursor.rewind(Cursor.SELECTION_END); // rewind to end of selection
		  if (cursor.tick == 0) {
			endTick = curScore.lastSegment.tick + 1;
		  } else {
			endTick = cursor.tick;
		  }
		  endStaff   = cursor.staffIdx;
		}
			
		var mtext = ""
            for (var staff = startStaff; staff <= endStaff; staff++) {
				mtext+="\nStaff "+(staff+1).toString()+"\n";
                var lastOctave = 0;
                var lastLength = "";
				
                for (var voice = 0; voice < (fullScore ? 4 : 1); voice++) {
                    
					cursor.rewind(Cursor.SELECTION_START); // beginning of selection
					cursor.voice = voice; //voice has to be set after goTo
                    cursor.staffIdx = staff;
                    
					cursor.rewind(fullScore  ? Cursor.SCORE_START : Cursor.SELECTION_START) // beginning of score
					if(cursor.segment && (fullScore || cursor.tick < endTick)) mtext+="Voice "+(voice+1).toString()+"\n"
                    while (cursor.segment && (fullScore || cursor.tick < endTick)) {
						
                        var e = cursor.element;
                        if (e) {

                            var currentLength = lengths[e.duration.ticks]

                                if (lastLength != currentLength) {
                                    if(durationList.key == 0) mtext += currentLength + " ";
									if(durationList.key == 2) mtext += parseFloat((e.duration.ticks / 1920).toFixed(4)) + " ";
                                    lastLength = currentLength;
                                }

                                if (e.type == Element.REST) {
									if(durationList.key == 1) mtext += currentLength;
                                    mtext += "r ";
                                }
                                if (e.type == Element.CHORD) {
									
                                    var notes = e.notes;
                                    if (notes) {
                                        for (var k = 0; k < notes.length; k++) {
                                            var note = notes[k];
											var rootNote = roots[cursor.keySignature+7]+octaveShift;
											var pitchShift = rootNote - 60;
                                            var octave = parseInt((note.pitch - pitchShift) / 12) - 5;
                                            var pc = parseInt(note.pitch - pitchShift) % 12;
                                            var npc = "";
											
											console.log(rootNote)

                                            var octaveChars = ""
											
                                                if (lastOctave != octave) {
                                                    if (octaveList.key==0) {
                                                     var octaveChars = ""
                                                           // if (octave < lastOctave) octaveChars = repeatStr("_", Math.abs(lastOctave - octave));
                                                           // if (octave > lastOctave) octaveChars = repeatStr("^", Math.abs(lastOctave - octave));
                                                            
                                                             //   mtext += octaveChars + " ";
														octaveChars = repeatStr((octave < lastOctave ? "_" : "^"), Math.abs(lastOctave - octave));
                                                        mtext += octaveChars + " ";
                                                    } else if(octaveList.key==2) {
                                                        mtext += "<" + octave + "> ";
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
												
												if(octaveList.key == 1 && octave!=0) mtext += repeatStr((octave < 0 ? "_" : "^"), Math.abs(octave));
												
												if(durationList.key == 1) mtext += currentLength;
												mtext += (scaleList.key==0 ? npc : pc.toString().replace('10','T').replace('11','E'))

                                        }
										mtext+=" "
                                    } 
                                }
                        }
                        cursor.next();
                    }
				}
				// Staffs
                mtext += "\n"
            }
           
        // outfile.write(mtext);
        resultDialog.openResultDialog(mtext);
    }

    onRun: {
        if (typeof curScore === 'undefined')
            Qt.quit();
    }
}
