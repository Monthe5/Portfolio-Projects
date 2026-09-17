
from pathlib import Path
import json
import numpy as np
from PIL import Image
import tensorflow as tf
import gradio as gr


 
# PATHS
 

BASE_DIR = Path(
    __file__
).resolve().parent


MODEL_PATH = (
    BASE_DIR
    /
    "models"
    /
    "maizeguard_best_efficientnetb0.keras"
)


CONFIG_PATH = (
    BASE_DIR
    /
    "data"
    /
    "metadata"
    /
    "maizeguard_inference_config.json"
)


 
# LOAD CONFIGURATION
 

with open(
    CONFIG_PATH,
    "r",
    encoding="utf-8"
) as f:

    config = json.load(f)


CLASS_NAMES = (
    config["class_names"]
)

IMG_SIZE = tuple(
    config["image_size"]
)


 
# LOAD MODEL
 

model = tf.keras.models.load_model(
    MODEL_PATH
)


 
# PREDICTION FUNCTION
 

def predict(image):

    if image is None:
        return {}


    image = image.convert(
        "RGB"
    )


    array = np.asarray(
        image,
        dtype=np.float32
    )


    tensor = tf.convert_to_tensor(
        array
    )


    tensor = tf.image.resize(
        tensor,
        IMG_SIZE,
        antialias=True
    )


    batch = tf.expand_dims(
        tensor,
        axis=0
    )


    probabilities = model.predict(
        batch,
        verbose=0
    )[0]


    return {

        CLASS_NAMES[i]:
            float(probabilities[i])

        for i in range(
            len(CLASS_NAMES)
        )
    }


 
# GRADIO INTERFACE
 

demo = gr.Interface(

    fn=predict,

    inputs=gr.Image(
        type="pil",
        label="Upload a maize leaf image"
    ),

    outputs=gr.Label(
        num_top_classes=4,
        label="Prediction"
    ),

    title="MaizeGuard",

    description=(
        "Upload a maize leaf photograph and MaizeGuard "
        "will classify it as Gray leaf spot, Common rust, "
        "Northern leaf blight, or Healthy. "
        "This is a prototype decision-support tool. "
        "Independent field validation is required before "
        "real-world agronomic use."
    ),
)


if __name__ == "__main__":

    demo.launch()
