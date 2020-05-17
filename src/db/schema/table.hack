namespace catarini\db\schema;

use catarini\db\schema\{ Column }; 

interface TableSchema { 
    
}


abstract class Table { 
    private vec<Column> $columns;

    public function __construct(string $name, vec<Column> $columns) { 
        $this->columns = $columns;
    }
}