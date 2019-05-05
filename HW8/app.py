# Creator: Chike Uduku
# Created: 05/03/2019
# Desc: Precipitation and Station Analysis API

########################## DEPENDENCIES ##############################################################
import datetime as dt
import sqlalchemy
from sqlalchemy.ext.automap import automap_base
from sqlalchemy.orm import Session
from sqlalchemy import create_engine, func
from sqlalchemy.orm import scoped_session, sessionmaker
from flask import Flask, jsonify
########################################################################################################

########################### SETUP FLASK ################################################################
app = Flask(__name__)
#########################################################################################################

############################ SESSION AND ENGINE #########################################################
#Initialize engine
engine = create_engine("sqlite:///Resources/hawaii.sqlite")

# reflect an existing database into a new model
Base = automap_base()
# reflect the tables
Base.prepare(engine, reflect=True)
# Save references to each table
Measurement = Base.classes.measurement
Station = Base.classes.station
# Create our session (link) from Python to the DB

db_session = scoped_session(sessionmaker(autocommit=False,
                                         autoflush=False,
                                         bind=engine))
#########################################################################################################

############################### FLASK ROUTES ###########################################################
@app.route("/")
def welcome():
    """List all available api routes."""
    return (
        f"Welcome to the Precipitation and Station analysis API!<br/>"
        f"Available Routes:<br/>"
        f"/api/v1.0/precipitation<br/>"
        f"/api/v1.0/stations<br/>"
        f"/api/v1.0/tobs<br/>"
        f"/api/v1.0/start<br/>"
        f"/api/v1.0/start/end"
    )

@app.route("/api/v1.0/precipitation")
def QueryPrecipitation():
    #Query for precipitation dates#and values 
    tempData = db_session.query(Measurement.date,Measurement.prcp).all() 

    #Now that we have precipitation dates and values , let's put them in a dictionary with 
    # precipitation dates as the keys
    prcpDict = {}
    for prcpDate,prcpValue in tempData:
        prcpDict[prcpDate] = prcpValue
    return jsonify(prcpDict) # return a jsonified form of the dictionary

@app.route("/api/v1.0/stations")
def QueryStations():
    tempData = db_session.query(Station.station).all() #Query for Stations
    return jsonify(tempData) # return a jsonified form of the dictionary

@app.route("/api/v1.0/tobs")
def QueryTobs():
    #Let's get date reflecting a year span from last date
    queryDate = dt.date(2017,8,23) - dt.timedelta(days = 365)
    
    tobsDict = {} #initialize dictionary to house temperature observations for previous year

    #Query for temperature observations from previous year
    tempData = db_session.query(Measurement.date,Measurement.tobs).filter(Measurement.date <='2017-8-23')\
    .filter(Measurement.date >= queryDate).all()
 
    # List of temperature observations
    for tobsDate,tobsValue in tempData:
        tobsDict[tobsDate] = tobsValue
    tobsList = [tobsDict]
    return jsonify(tobsList)

@app.route("/api/v1.0/<start>")
def QueryStart(start):
    try:
        #Min Temp
        startMinTemp = db_session.query(func.min(Measurement.tobs)).filter(Measurement.date >= start).all() 
        #Max Temp
        startMaxTemp = db_session.query(func.max(Measurement.tobs)).filter(Measurement.date >= start).all()
        #Average Temp
        startAvgTemp = db_session.query(func.avg(Measurement.tobs)).filter(Measurement.date >= start).all()
        # Make a list of tempperature results
        startTempList = [{"Min Temp":startMinTemp,"Max Temp":startMaxTemp,"Average Temp":startAvgTemp}] 
        return jsonify(startTempList)# jsonify list
    except:
        return jsonify({"Error":"Please check date format"})

    
@app.route("/api/v1.0/<start>/<end>")
def QueryStartEnd(start,end):
    try:
        startEndMinTemp = db_session.query(func.min(Measurement.tobs)).filter(Measurement.date <=end)\
        .filter(Measurement.date >= start).all()
        
        startEndMaxTemp = db_session.query(func.max(Measurement.tobs)).filter(Measurement.date <=end)\
        .filter(Measurement.date >= start).all()
        
        startEndAvgTemp = db_session.query(func.avg(Measurement.tobs)).filter(Measurement.date <=end)\
        .filter(Measurement.date >= start).all()
        # Make a list of temperature results
        startEndTempList = [{"Min Temp":startEndMinTemp,"Max Temp":startEndMaxTemp,"Average Temp":startEndAvgTemp}] 
        return jsonify(startEndTempList)
    except:
        return jsonify({"Error":"Please check date format"})
#########################################################################################################

###################################### RUN FLASK ########################################################
if __name__ == '__main__':
    app.run(debug=True)