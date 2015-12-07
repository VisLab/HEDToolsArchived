package edu.utsa.tagger.database;

import org.junit.runner.RunWith;
import org.junit.runners.Suite;
import org.junit.runners.Suite.SuiteClasses;

@RunWith(Suite.class)
@SuiteClasses({ TestDOMTree.class, TestEvents.class, TestManageDB.class,
		TestTagAttributes.class, TestTagComments.class, TestTags.class })
public class AllUnitTests {

}
