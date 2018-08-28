public class PartnerSalesOrder implements IProcessDefinition {

    private static final List<String> steps = new List<String>{
        B24ConfirmMsgDeliveryStep.class.getName()
    };

    public Queue getStepsQueue() {
        return new Queue(steps);
    }

    public String getProcessName() {
        return 'PartnerSalesOrder';
    }

}