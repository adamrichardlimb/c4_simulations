from PIL import Image

# Load the GIF image
image_path = "C:/Users/Adam/Downloads/barcode.gif"
image = Image.open(image_path)

# Define a function to convert a pixel to "#" for black and "." for white
def convert_pixel_to_char(pixel):

    if pixel == 0:  # Check if pixel is black
        return "#"
    else:
        return "."

# Process each pixel and create the text representation
text_representation = ""
for y in range(image.height):
    for x in range(image.width):
        pixel = image.getpixel((x, y))
        char = convert_pixel_to_char(pixel)
        text_representation += char
    text_representation += "\n"  # Newline after each row

# Create a text file with the converted characters
text_file_path = "barcode_text.txt"
with open(text_file_path, "w") as text_file:
    text_file.write(text_representation)

print(text_representation)
