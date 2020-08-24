#
# bites per window data -- trying fitting to continuous value instead of
# class labels -- started with integer values, then switched to
# floating point values that are fractions of bites
# switched normalization to numpy (whole array at a time instead of
#   one element at a time)
# windata not capped at 6.0; instead, capping it here if desired
#

import logging
logging.getLogger('tensorflow').disabled = True

# TensorFlow, keras, np
import tensorflow as tf
from tensorflow import keras
import numpy as np
import time

# open file
f=open('2GBwindata.txt','r')
d=[[float(x) for x in line.split()] for line in f]
f.close()

# copy to classes and data
classes=[]
data=[]

total_axes=6

# separate data into one row per axis for normalizing
for a in range(0,len(d)):
  if d[a][0] > 6.0:
    print(d[a][0]," is greater than 6.0")
    classes.append(6.0)
  else:
    classes.append(d[a][0])
  for axis in range(0,total_axes):
    row=[]
    for b in range(1+axis,len(d[a]),total_axes):
      row.append(d[a][b])
    data.append(row)

#print(classes)
#print(data)

classes=np.array(classes)
data=np.array(data)

print("data has shape", data.shape)
print("classes has shape ", classes.shape)

# normalize each row of data
start=time.time()
normdata=np.empty_like(data)
for a in range(0,len(data)):
  norm=[]
  s=min(data[a])
  t=max(data[a])
  if s == t:
    t=s+1
  normdata[a]=(data[a]-s)/(t-s)
end=time.time()
print("data normalized in ",end-start," seconds")

# copy normdata back to data variable so rest of code remains unchanged
data=normdata


# reshape data to flatten it to one row per recording
data_flat=data.reshape(len(classes),len(data[0])*total_axes)
print("data_flat has shape ", data_flat.shape)

model = keras.Sequential([
    keras.layers.Reshape((450,total_axes), input_shape=(2700,)),
    keras.layers.Conv1D(filters=100,kernel_size=30,strides=15,
		activation='relu'),
    keras.layers.Conv1D(filters=100,kernel_size=5,
		activation='relu'),
    keras.layers.Flatten(),  # must flatten to feed dense layer
    keras.layers.Dense(1)
    ])

model.compile(optimizer='adam',
              loss='mean_squared_error',
              metrics=['mean_absolute_error'])

model.summary()

print("Training")
metrics = model.fit(data_flat, classes, epochs=100,
    validation_split=0.2, verbose=2)

print("Testing")
test_loss, test_acc = model.evaluate(data_flat, classes)
print('Test accuracy:', test_acc)

predictions = model.predict(data_flat)
print('Actual, prediction:')
for a in range(0,len(classes)):
  print(classes[a],predictions[a])

tf.keras.models.save_model(model,'model-windows-2GB.hd5',True,True)

