# Azure Container Instances Hello World

This sample is a simple NodeJS application used to demonstrate [Azure Container Instances](https://azure.microsoft.com/services/container-instances/) with secure Azure Container Registry (ACR) authentication.

The packaged version of the application is [available on Docker Hub](https://hub.docker.com/r/microsoft/aci-helloworld/).

## Project Components

- **Simple Node.js Web App**: A basic Express application serving a hello world page
- **ACR Authentication Scripts**: Utilities to create and manage service principals for Azure Container Registry access
- **Documentation**: Detailed guides on ACR authentication and setup

## Getting Started

1. Clone this repository
2. Set up ACR authentication:

   ```powershell
   .\scripts\Run-AcrSetup.ps1
   ```

3. Build and push the container:

   ```powershell
   .\scripts\Run-DockerLogin.ps1
   docker build -t yourregistry.azurecr.io/aci-helloworld .
   docker push yourregistry.azurecr.io/aci-helloworld
   ```

For detailed documentation on ACR authentication, see:

- [ACR Authentication Guide](docs/acr-auth.md)
- [ACR Authentication Setup](docs/acr-auth-setup.md)

## Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit <https://cla.microsoft.com>.

When you submit a pull request, a CLA-bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., label, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.
