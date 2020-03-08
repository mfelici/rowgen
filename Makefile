CXX = g++
CXXFLAGS = -O3 -D HAVE_LONG_INT_64 -Wall -std=c++11 -shared -Wno-unused-value -fPIC
INCPATH = -I/opt/vertica/sdk/include
VERPATH = /opt/vertica/sdk/include/Vertica.cpp
UDXLIBNAME = lrowgen
UDXLIB = /tmp/$(UDXLIBNAME).so
UDXSRC = $(UDXLIBNAME).cpp

compile: $(UDXSRC)
	$(CXX) $(CXXFLAGS) $(INCPATH) -o $(UDXLIB) $(UDXSRC) $(VERPATH)

deploy: $(UDXLIB)
	@echo " \
	    CREATE OR REPLACE LIBRARY $(UDXLIBNAME) AS '$(UDXLIB)' LANGUAGE 'C++'; \
	    CREATE OR REPLACE TRANSFORM FUNCTION rowgen AS LANGUAGE 'C++' NAME 'RowGenFactory' LIBRARY $(UDXLIBNAME) ; \
		GRANT EXECUTE ON TRANSFORM FUNCTION rowgen(x integer) TO PUBLIC ; \
	" | vsql -U dbadmin  -X -f - -e
test: 
	@echo " \
	    SELECT rowgen(10) OVER() ; \
	" | vsql -U dbadmin  -X -f - -e
clean:
	@echo " \
	    DROP LIBRARY $(UDXLIBNAME) CASCADE ; \
	" | vsql -U dbadmin  -X -f - -e
