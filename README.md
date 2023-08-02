# Concatenate PDFs

This command-line tool will concatenate all pages of multiple PDF files together into one PDF file. 

## Usage

```
concatenate_pdfs -d concatenated.pdf first.pdf second.pdf third.pdf
```

## Build the command-line tool

- Clone the github repository to your Mac that has the Xcode command line tools installed.
- Run the script `build_release.sh`.
- Copy the built executable located at `.build/apple/Products/Release/concatenate_pdfs` to a convenient location like `/usr/local/bin`

