package fr.treeptik.cloudunit.integration.scenarii.deployments;

public class Tomcat8DeploymentControllerTestIT
    extends AbstractDeploymentControllerTestIT
{
    public Tomcat8DeploymentControllerTestIT()
    {
        super.release = "tomcat-8";
    }
}
