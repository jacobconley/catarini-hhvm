namespace catarini\db\migration;

use Facebook\HackCodegen\{
    CodegenFileType,
    HackCodegenConfig,
    HackCodegenFactory,
    HackBuilderValues,
    HackBuilder
};

use HH\Lib\{ Vec };

use catarini\db\schema\{ Schema, Table, Column, Reference, Cardinality, RelationshipEnd, Relationship }; 
use function catarini\db\typeToString;


class SchemaWriter { 

    private Schema $schema; 
    private string $dir; 

    public function __construct(Schema $schema, string $dir) { 
        $this->schema = $schema;  
        $this->dir = $dir; 
    }    


    private function _hackReference(HackBuilder $cb, ?Reference $ref, vec<Table> $tables) : void { 
        if($ref is null) { 
            $cb->add('NULL');
            return; 
        }

        $t_i /* u can have whatever u like */ = Vec\first_key($tables,  $x ==> $x->getName() === $ref->getReferencedTable()->getName());
        $table = "\$tables[$t_i]";

        $cb->indent();
        $cb->ensureNewLine();
        $cb->addf("(new Reference(%s, ReferenceAction::%s, ReferenceAction::%s))", $table, $ref->getUpdateAction() as string, $ref->getDeleteAction() as string);
        $cb->addIf($ref->isNullable(), "->nullable()");

        $cb->unindent();
        $cb->ensureNewLine();
    }

    private function _hackColumn(HackBuilder $cb, Column $col, vec<Table> $tables) : void { 
        $type = $col->getType();

        $def = $col->_str_default();
        $con = $col->_str_condition();

        $cb->addf('(new Column(%s, "%s", ', 'Type::'.typeToString($type), $col->getName());
        $this->_hackReference($cb, $col->getReference(), $tables); 
        $cb->addf(', %s))',   $col->isPrimary() ? 'TRUE' : 'FALSE');

        if(! $col->isNullable())    $cb->addf('->nonnull()');
        if($col->isUnique())        $cb->addf('->unique()');
        if($def is nonnull)         $cb->addf('->default(%s)', $def); 
        if($con is nonnull)         $cb->addf('->check(%s)', $con); 

        $cb->add(',');
        $cb->ensureNewLine();
    }


    private function _hackTable(HackBuilder $cb, Table $table, vec<Table> $previous) : void { 
        $cb->addf('$tables[] = new Table("%s", vec[', $table->getName());
        $cb->ensureNewLine();
        $cb->indent();

        foreach($table->getColumns() as $col) $this->_hackColumn($cb, $col, $previous);

        $cb->unindent();
        $cb->addf(']);');
        $cb->ensureEmptyLine();
    }





    public function writeHack(?string $namespace) : void { 
        $dir = $this->dir; 
        \catarini\util\ensure_dir($dir); 
        $path = $dir.'schema.php';  //TODO: Change to .hack when updating codegen version?
                                    // This oughtta be logged..

        echo "[-] Writing $path\n"; 

        $hack = new HackCodegenFactory(new HackCodegenConfig()); 
        $cg = $hack->codegenFile($path);
        if($namespace is nonnull) $cg->setNamespace($namespace); 


        $tables = $this->schema->getTables(); 
        $tbc = $hack->codegenHackBuilder();
        foreach($tables as $table) { 
            $this->_hackTable($tbc, $table, $tables);
        }

        
        $cg->useNamespace('catarini\db')
            ->useType('catarini\db\Type')
            ->useType('catarini\db\schema\{ Table, Column, Schema, Reference, ReferenceAction, Relationship, RelationshipEnd, Cardinality }')

            ->addFunction(
                $hack->codegenFunction('_db_schema')
                    ->setReturnType('Schema')
                    ->setBody(

                        $hack->codegenHackBuilder()


                            ->add('$tables = vec[];')
                            ->ensureEmptyLine()
                            ->add($tbc->getCode())


                            ->add('$relationships = vec[];')
                            ->ensureNewLine()

                            //TODO: Relationships ! 

                            // ->ensureNewLine()
                            // ->add('];')



                            ->ensureEmptyLine()
                            ->add('return new Schema($tables, $relationships);')
                            ->ensureNewLine()

                            ->getCode()
                    )
        );

        $cg->save();
    }

}