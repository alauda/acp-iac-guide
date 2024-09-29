# IaC Guidebook For ACP - Terraform Edition

This little guide provides detailed instructions on implementing Infrastructure as Code (IaC) practices using Terraform within the Alauda Container Platform (ACP) environment.

## Local Development

### Environment Setup

1. Ensure you have Python 3.x installed
2. Install dependencies:
   ```
   pip install -r requirements.txt
   ```

### Local Preview

Use the following command to preview the website locally:
```
make serve
```
Then in your browser, open http://localhost:8000 to view the website.

### Build Static Website

Use the following command to build the static website:
```
make build
```
The built files will be located in the `site/` directory.

### Generate PDF

Use the following command to generate the PDF:
```
make pdf
```
The generated PDF file will be named `terraform-guide.pdf`.

## Automated Deployment

This project uses GitHub Actions for automated deployment. Every time you push to the `main` branch, the following actions will be triggered:

1. Build the MkDocs static website
2. Deploy the static website to GitHub Pages
3. Generate the PDF file
4. Create a new Release
5. Upload the PDF file to the Release

You can view the detailed workflow configuration in the `.github/workflows/build-and-deploy.yml` file.