SELECT SR.PATIENTLICENSENUMBER,
	L.LICENSE_NUMBER,
	L.LICENSE_NAME LICENSE1,
	L2.LICENSE_NUMBER,
	L2.LICENSE_NAME LICENSE2,
	L.PHYSICAL_ADDRESS || ' ' || L.PHYSICAL_CITY ADDRESS1,
	L2.PHYSICAL_ADDRESS || ' ' || L2.PHYSICAL_CITY ADDRESS2,
	TRUNC((EARTH_DISTANCE(LL_TO_EARTH(X.Y::FLOAT8,X.X::FLOAT8),LL_TO_EARTH(X2.Y::FLOAT8,X2.X::FLOAT8)) / 1609)::numeric,2) AS DISTANCE_BETWEEN_STORES,
	SR.RECEIPTNUMBER,
	SR2.RECEIPTNUMBER,
	SR.TOTALPRICE::FLOAT8::numeric::MONEY AS SALE1,
	SR2.TOTALPRICE::FLOAT8::numeric::MONEY AS SALE2,
	TO_CHAR(SR.SALESDATETIME,'mm/dd/yyyy hh:mi:ss AM') SALESDATETIME1,
	TO_CHAR(SR2.SALESDATETIME,'mm/dd/yyyy hh:mi:ss AM') SALESDATETIME2,
	SR.SALESDATETIME - SR2.SALESDATETIME AS TIME_BETWEEN,
	(EARTH_DISTANCE(LL_TO_EARTH(X.Y::FLOAT8,X.X::FLOAT8),LL_TO_EARTH(X2.Y::FLOAT8,X2.X::FLOAT8)) / 1609::int) / (EXTRACT(EPOCH FROM SR.SALESDATETIME - SR2.SALESDATETIME) / 3600) AS SPEED_TO_MAKE_TRIP_MPH
FROM METRC.SALESRECEIPT SR
JOIN METRC.SALESRECEIPT SR2 ON SR.PATIENTLICENSENUMBER = SR2.PATIENTLICENSENUMBER
AND CAST (SR.SALESDATETIME AS date) = CAST (SR2.SALESDATETIME AS date)
AND LENGTH(SR.PATIENTLICENSENUMBER) > 5
AND SR.FACILITYID <> SR2.FACILITYID
AND SR.RECEIPTNUMBER <> SR2.RECEIPTNUMBER
AND SR.SALESDATETIME > SR2.SALESDATETIME
AND SR.SALESCUSTOMERTYPE = 2
AND SR2.SALESCUSTOMERTYPE = 2
AND SR.SALESDATETIME > '1-jan-2022'
AND SR.ISARCHIVED = FALSE
AND SR2.ISARCHIVED = FALSE
LEFT JOIN MYLO.LICENSE L ON L.METRC_FACILITY_ID = SR.FACILITYID
LEFT JOIN XY_COORDINATES X ON X.LICENSE_ID = L.LICENSE_ID
JOIN MYLO.LICENSE L2 ON L2.METRC_FACILITY_ID = SR2.FACILITYID
JOIN XY_COORDINATES X2 ON X2.LICENSE_ID = L2.LICENSE_ID
WHERE (EARTH_DISTANCE(LL_TO_EARTH(X.Y::FLOAT8,X.X::FLOAT8),LL_TO_EARTH(X2.Y::FLOAT8,X2.X::FLOAT8)) / 1609::int) / (EXTRACT(EPOCH FROM SR.SALESDATETIME - SR2.SALESDATETIME) / 3600) > 65
ORDER BY 16 DESC --MPH FASTEST TO SLOWEST
