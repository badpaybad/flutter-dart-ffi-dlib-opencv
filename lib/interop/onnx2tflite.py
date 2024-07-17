# pip install -U onnx-tf==1.10.0

# pip install tensorflow-cpu==2.16.1
# pip install keras==2.15.0
# pip install tensorflow-cpu==2.13.1
# pip install -U tensorflow_probability
import onnx
from onnx_tf.backend import prepare

# Load the ONNX model
modelprefix= "updated"
modelpath=f"/work/{modelprefix}-resnet100.onnx"
onnx_model = onnx.load(modelpath)

# Convert the ONNX model to TensorFlow
tf_rep = prepare(onnx_model)
tf_rep.export_graph(f'{modelprefix}_resnet100_tf')

import tensorflow as tf

# Convert the TensorFlow SavedModel to TFLite
converter = tf.lite.TFLiteConverter.from_saved_model(f"{modelprefix}_resnet100_tf")
tflite_model = converter.convert()

# Save the TFLite model to a file
with open(f"{modelprefix}_resnet100.tflite", 'wb') as f:
    f.write(tflite_model)
