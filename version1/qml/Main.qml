import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15

ApplicationWindow {
    id: root
   //width: Screen.width
   //height: Screen.height
    
    width: 800
    height: 480
    visible: true
    color: "#1E1E1E"
    title: "ReplicaVersion"

    // ------------ PAGE FLAGS ------------
    property bool showSplash: true
    property bool showHome: false

    property bool showSavedTractors: false
    property bool showTractorForm: false

    property bool showSavedImplements: false
    property bool showImplementForm: false

    property bool showSavedFarms: false
    property bool showAddFarm: false
    property bool showPlotFarm: false
    property bool showTraceFarm: false

    property bool showViewFarm: false      // map-only farm view
    property bool showGeneratePath: false
    property bool showWifiPage: false

    // FARM LOAD DATA
    property string loadedFarmName: ""
    property string loadedFarmJson: ""

    // ------------ SPLASH TIMER ------------
    Timer {
        interval: 2000
        running: true
        repeat: false
        onTriggered: {
            showSplash = false
            showHome = true
        }
    }

    // ------------ NAVIGATION STACK ------------
    StackLayout {
        anchors.fill: parent

        // index must match order of children below
        currentIndex:
            showSplash          ? 0 :
            showHome            ? 1 :
            showSavedTractors   ? 2 :
            showTractorForm     ? 3 :
            showSavedImplements ? 4 :
            showImplementForm   ? 5 :
            showSavedFarms      ? 6 :
            showAddFarm         ? 7 :
            showPlotFarm        ? 8 :
            showTraceFarm       ? 9 :
            showViewFarm        ? 10 :
            showGeneratePath    ? 11 :
            showWifiPage        ? 12 :
            1

        // 0 — Splash
        Item {
            Rectangle {
                anchors.fill: parent
                color: "#222"
                Column {
                    anchors.centerIn: parent
                    Image {
                        source: "qrc:/images/logo.png"
                        fillMode: Image.PreserveAspectFit
                        sourceSize.width: 140
                    }
                }
            }
        }

        // 1 — HomePage
        HomePage {
            id: homePage
            anchors.fill: parent

            onTractorClicked: {
                showHome = false
                showSavedTractors = true
            }
            
             onImplementClicked: {
                showHome = false
                showSavedImplements = true
            }
            onFarmLandClicked: {
                showHome = false
                showSavedFarms = true
            }
            onPathClicked: {
                showHome = false
                showGeneratePath = true
            }
            onSettingsClicked: {
                showHome = false
                showWifiPage = true
            }

        
        }
        
        // 2 — Saved Tractors
        SavedTractorsPage {
            id: savedTractors
            anchors.fill: parent
            onBackPressed: {
                showSavedTractors = false
                showHome = true
            }
            onAddNew: {
                showSavedTractors = false
                showTractorForm = true
            }
        }
        
        // 3 — Tractor Form
        TractorPage {
            id: tractorForm
            anchors.fill: parent
            onBackPressed: {
                showTractorForm = false
                showSavedTractors = true
            }
            onSaved: {
                showTractorForm = false
                showSavedTractors = true
            }
        }
        
         // 4 — Saved Implements
        SavedImplementsPage {
            id: savedImplements
            anchors.fill: parent
            onBackPressed: {
                showSavedImplements = false
                showHome = true
            }
            onAddNew: {
                showSavedImplements = false
                showImplementForm = true
            }
        }

        // 5 — Implement Form
        ImplementPage {
            id: implementForm
            anchors.fill: parent

            onBackPressed: {
                showImplementForm = false
                showSavedImplements = true
            }
            onSaved: {
                showImplementForm = false
                showSavedImplements = true
            }
        }
        
          // 6 — Saved Farms
        SavedFarmPage {
            id: savedFarmPage
            anchors.fill: parent

            onBackPressed: {
                showSavedFarms = false
                showHome = true
            }

            onAddNewFarm: {
                showSavedFarms = false
                showAddFarm = true
            }

            // Open VIEW-ONLY map with the saved polygon
            onFarmSelected: function(name, jsonData) {
                loadedFarmName = name
                loadedFarmJson = jsonData
                showSavedFarms = false
                showViewFarm = true
            }
        }

        // 7 — Add Farm page (menu)
        AddFarmPage {
            id: addFarmPage
            anchors.fill: parent
            onBackPressed: {
                showAddFarm = false
                showSavedFarms = true
            }
            onPlotFarm: {
                showAddFarm = false
                showPlotFarm = true
            }
            onTraceFarm: {
                showAddFarm = false
                showTraceFarm = true
            }
        }

        // 8 — Plot Farm page (full editor)
        PlotFarmPage {
            id: plotFarmView
            anchors.fill: parent
            onBackPressed: {
                showPlotFarm = false
                showSavedFarms = true
            }
            onFarmSaved: {
                showPlotFarm = false
                showSavedFarms = true
            }
        }

        // 9 — Trace Farm page
        TraceFarmPage {
            id: traceFarm
            anchors.fill: parent
            onBackPressed: {
                showTraceFarm = false
                showAddFarm = true
            }
            onFarmTracedSaved: {
                showTraceFarm = false
                showSavedFarms = true
            }
        }

        // 10 — View Farm (map only, uses map_view.html)
        ViewFarmPage {
            id: viewFarmPage
            anchors.fill: parent
            farmJson: loadedFarmJson

            onBackPressed: {
                showViewFarm = false
                showSavedFarms = true
            }
        }

        // 11 — Generate Path page
        GeneratePathPage {
            id: pathPage
            anchors.fill: parent
            onBackPressed: {
                showGeneratePath = false
                showHome = true
            }
        }

        // 12 — Wifi page
        WifiPage {
            id: wifiPage
            anchors.fill: parent

            onBackRequested: {
                showWifiPage = false
                showHome = true
            }
        }
  
    
    }
}

