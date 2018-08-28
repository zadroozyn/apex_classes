public interface IProcessStepDefinition {
	void executeStep(ProcessRealization pInstance);
	String getStepName();
}