    function _test_dir() : string { 
        return realpath(dirname(__FILE__)."/../test-fixture/");
    }
    
    function _test_db() : catarini\db\DatabaseInstance { 
        catarini\meta\CONFIG::_forceRoot(_test_dir());
        return Catarini::GET()->db(); 
    }

    function _test_namespace() : string { return '_catarini_test'; }