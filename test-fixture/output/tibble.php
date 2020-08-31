<?hh // strict
/**
 * This file is generated. Do not modify it manually!
 *
 * @generated SignedSource<<c1251d17937e8f12af875264a9d9b6e6>>
 */
namespace _catarini_test;
use namespace catarini\db;
use type catarini\db\Type;
use type catarini\db\schema\Table;
use type catarini\db\schema\Column;
use type catarini\db\querying\Entity;
use type catarini\db\querying\EntityQuery;
use function catarini\db\type\__sql_val;
use function catarini\db\type\__sql_val_opt;

class tibble {

  public vec<string> $__sql_cols = vec[
    'test',
  ];
  private ?int $test;

  public function __construct(?int $test) {
    $this->test = $test;
  }

  public static function from_sql(dict<string, ?string> $row): tibble {
    $test = __sql_val_opt<int>(Type::INT, 'test', $row['test'], NULL);
    return new tibble($test);
  }
}
