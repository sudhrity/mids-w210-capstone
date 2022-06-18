import warnings

import numpy as np
from datasets import load_dataset, load_metric
from transformers import (
    AutoConfig,
    AutoModelForSequenceClassification,
    AutoTokenizer,
    Trainer,
    TrainingArguments,
)

warnings.filterwarnings("ignore")

task = "sst2"
model_checkpoint = "distilbert-base-uncased"
batch_size = 256  # training on A4000 this takes 15 GB/GPU

dataset = load_dataset("glue", task)
metric = load_metric("glue", task)

tokenizer = AutoTokenizer.from_pretrained(model_checkpoint, use_fast=True)


def preprocess(examples):
    return tokenizer(examples["sentence"], truncation=True)


encoded_dataset = dataset.map(preprocess, batched=True)

label2id = {"NEGATIVE": 0, "POSITIVE": 1}
id2label = {v: k for k, v in label2id.items()}
config = AutoConfig.from_pretrained(
    model_checkpoint, label2id=label2id, id2label=id2label
)
model = AutoModelForSequenceClassification.from_pretrained(
    model_checkpoint, config=config
)

model_name = model_checkpoint.split("/")[-1]

args = TrainingArguments(
    f"{model_name}-finetuned-{task}",
    evaluation_strategy="epoch",
    save_strategy="epoch",
    learning_rate=2e-5,
    per_device_train_batch_size=batch_size,
    per_device_eval_batch_size=batch_size,
    num_train_epochs=5,
    weight_decay=0.01,
    load_best_model_at_end=True,
    metric_for_best_model="accuracy",
    push_to_hub=True,
)


def compute_metrics(eval_pred):
    predictions, labels = eval_pred
    predictions = np.argmax(predictions, axis=1)
    return metric.compute(predictions=predictions, references=labels)


trainer = Trainer(
    model,
    args,
    train_dataset=encoded_dataset["train"],
    eval_dataset=encoded_dataset["validation"],
    tokenizer=tokenizer,
    compute_metrics=compute_metrics,
)

trainer.train()
trainer.evaluate()
trainer.push_to_hub()
