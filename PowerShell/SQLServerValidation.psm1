Add-Type -Language CSharpVersion3 -UsingNamespace System -TypeDefinition @"
	namespace BestPracticeValidation.SQLServerTesting {
		public interface ISQLServerTest {
			void PerformTest();
		}
	}
"@
Add-Type -Language CSharpVersion3 -UsingNamespace System -TypeDefinition @"
	namespace BestPracticeValidation.SQLServerTesting {
		public abstract class AbstractSQLServerTest {
			protected abstract String Server;
			protected abstract Boolean Status;
			protected abstract void PerformTest();
		}
	}
"@
Add-Type -Language CSharpVersion3 -UsingNamespace System -TypeDefinition @"
	namespace BestPracticeValidation.SQLServerTesting {
		public class SQLServerTestResult {
			private Boolean success = false;
			public Boolean Success {
				get {return this.success}
			}
			private String reason = false;
			public String Reason {
				get {return this.reason}
			}
			public SQLServerTestResult(Boolean status, String reason) {
				this.success = success;
				this.reason = reason;
			}
		}
	}
"@
Add-Type -Language CSharpVersion3 -UsingNamespace System,System.Collections.Generic -TypeDefinition @"
	namespace BestPracticeValidation.SQLServerTesting {
		public class SQLServerTestCollection {
			private List<AbstractSQLServerTest> sQLServerTests = new List<AbstractSQLServerTest>();
			public List<AbstractSQLServerTest> SQLServerTests {
				get {
					return this.sQLServerTests;
				}
			}
			public void ExecuteTests() {
				foreach(AbstractSQLServerTest sQLServerTest in sQLServerTests) {
					sQLServerTest.PerformTest();
				}
			}
		}
	}
"@
Function Test-TraceFlags {
	Param(
		[Parameter(Mandatory=$true)]
		[ISQLServerTest]$SQLServerTest
	)
}
Function Test-DiskFormatting {
	Param(
		[Parameter(Mandatory=$true)]
		[ISQLServerTest]$SQLServerTest
	)
}
Function Test-DiskPermissions {
	Param(
		[Parameter(Mandatory=$true)]
		[ISQLServerTest]$SQLServerTest
	)
}
Function Test-MaxServerMemory {
	Param(
		[Parameter(Mandatory=$true)]
		[ISQLServerTest]$SQLServerTest
	)
}
Function Test-SystemCPUs {
	Param(
		[Parameter(Mandatory=$true)]
		[ISQLServerTest]$SQLServerTest
	)
}
Function Test-SystemMemory {
	Param(
		[Parameter(Mandatory=$true)]
		[ISQLServerTest]$SQLServerTest
	)
}
Function Test-OptimizeForAdHocWorkloadsIsEnabled {
	Param(
		[Parameter(Mandatory=$true)]
		[ISQLServerTest]$SQLServerTest
	)
}
Function Test-TempDbConfiguration {
	Param(
		[Parameter(Mandatory=$true)]
		[ISQLServerTest]$SQLServerTest
	)
}
Function Test-SQLServiceAccountsAreDistinct {
	Param(
		[Parameter(Mandatory=$true)]
		[ISQLServerTest]$SQLServerTest
	)
}
Function Test-SQLServiceAccountsAreGMSAs {
	Param(
		[Parameter(Mandatory=$true)]
		[ISQLServerTest]$SQLServerTest
	)
}

Export-ModuleMember -Function 'Test-*'