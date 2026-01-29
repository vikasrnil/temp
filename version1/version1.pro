TARGET = version1
TEMPLATE = app

QT += quick core gui network serialport webengine
CONFIG += c++17 release

SOURCES += main.cpp \
	   farmbackend.cpp \
	   GpsDataManager.cpp \
	   GpsPathModel.cpp \
	   implement.cpp \
	   Connection.cpp \
	   operations.cpp
	   
HEADERS += farmbackend.h \
	   GpsDataManager.h \
	   GpsPathModel.h \
	   implement.h \
	   Connection.h \
	   operations.h

RESOURCES += qml.qrc
