# MaizeGuard Model Card

## Purpose

MaizeGuard is an image-classification prototype for four
maize leaf states:

Gray leaf spot, Common rust, Northern leaf blight, Healthy.

## Dataset

Source: PlantVillage maize subset.

Leakage-safe split sizes:

- Train: 2620
- Validation: 462
- Test: 770

The split strategy was designed to keep physical leaf
identities separate between train, validation, and test.

## Model

- Architecture: EfficientNetB0
- Initialization: ImageNet pretrained weights
- Input size: 224 x 224
- Output classes: 4
- Model-selection data: validation split
- Final internal evaluation data: untouched test split

## PlantVillage test performance

- Accuracy: 0.9805
- Macro-F1: 0.9736


## Field validation

Independent real-world field validation has not yet been
completed.

Phase 9 should not be marked complete until a genuinely
independent, appropriately labeled field dataset has been
evaluated.


## Explainability

Grad-CAM is provided to visualize image regions that
influence a prediction.

Grad-CAM is a diagnostic explanation of model attention
and should not be interpreted as evidence that the
highlighted regions are biologically causal.

## Deployment

The project includes:

- A trained EfficientNetB0 model
- A TensorFlow Lite inference model
- A reusable prediction pipeline
- A Gradio application
- Inference metadata

## Limitations

- PlantVillage images are considerably more controlled
  than many real farm photographs.
- Performance may decrease under unfamiliar lighting,
  backgrounds, cameras, disease severities, cultivars,
  geographic regions, or mixed symptoms.
- The four output classes do not represent every maize
  disease, pest, nutrient deficiency, or physical injury.
- High model confidence does not guarantee correctness.
- Field performance should be evaluated independently
  before practical agricultural use.

## Intended use

Research, portfolio demonstration, machine-learning
experimentation, and prototype decision support.

## Not intended as

A replacement for agronomists, plant pathologists,
laboratory diagnosis, or locally validated crop-management
guidance.
