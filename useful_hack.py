from PyPDF2 import PdfReader, PdfWriter

def unlock_pdf_file():
	input_pdf = "input.pdf"
	output_pdf = "output.pdf"
	password = "yourpassword"
	reader = PdfReader(input_pdf)
	reader.decrypt(password)
	writer = PdfWriter()
	for page in reader.pages:
	    writer.add_page(page)

	# Save the decrypted PDF
	with open(output_pdf, "wb") as f:
	    writer.write(f)

	print("PDF unlocked and saved as:", output_pdf)

