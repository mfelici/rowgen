#include "Vertica.h"

using namespace Vertica;
using namespace std;

class RowGen : public TransformFunction
{
    virtual void processPartition(ServerInterface &srvInterface,
                                  PartitionReader & inputReader,
                                  PartitionWriter & outputWriter)
	{
		try
		{
			const vint nrows = inputReader.getIntRef(0);

			for ( vint i = 1 ; i <= nrows ; i++, outputWriter.next() ) 
				outputWriter.setInt( 0 , i ) ;
		}
		catch (exception& e)
		{
			vt_report_error(0, "Exception while processing partition: [%s]", e.what());
		}
	}
};

class RowGenFactory : public TransformFunctionFactory
{
	virtual void getPrototype(ServerInterface &srvInterface,
                              ColumnTypes &argTypes,
                              ColumnTypes &returnType )
	{
		argTypes.addInt();
		returnType.addInt();
	}
	virtual void getReturnType(ServerInterface &srvInterface,
                               const SizedColumnTypes &inputTypes,
                               SizedColumnTypes &outputTypes )
	{
		outputTypes.addInt( "series" );
	}
	virtual TransformFunction *createTransformFunction( ServerInterface &srvInterface )
	{
		return vt_createFuncObject<RowGen>(srvInterface.allocator);
	}
};
RegisterFactory(RowGenFactory);
