from tqdm import tqdm
import json
import os
os.environ["MODEL_DIR"] = '../model'
import nlpaug.augmenter.word as naw
from multiprocessing import Pool

ins_aug = naw.ContextualWordEmbsAug(
    model_path='bert-base-uncased', action='insert', aug_p=0.6, aug_max=1000000)
sub_aug = naw.ContextualWordEmbsAug(
    model_path='bert-base-uncased', action='substitute', aug_p=0.6, aug_max=1000000)
#ins_aug = naw.SynonymAug(aug_src='wordnet')
#sub_aug = naw.SynonymAug(aug_src='ppdb', model_path='/mnt/disks/disk1/nlpaug/ppdb/ppdb-2.0-tldr')

def get_max_sent_id(dataset):
    max_sent_id = -1
    for image in captions['images']:
        for sentence in image['sentences']:
            max_sent_id = max(max_sent_id, sentence['sentid'])
    return max_sent_id


def augment_sentence(sentence, ins_aug, sub_aug):
    all_variants = []
    text = ' '.join(sentence['tokens'])
    augmented_variants = []
    #augmented_variants = ins_aug.augment(text, n=2)
    more_variants = [sub_aug.augment(text, n=1)]
    augmented_variants += more_variants
    all_variants += augmented_variants
    return all_variants


def construct_dataset_sentence(sentence, base_sentence, max_id):
    base_sentence['tokens'] = sentence.split()
    base_sentence['raw'] = sentence
    base_sentence['sentid'] = max_id + 1
    return base_sentence


def augment_dataset(dataset, ins_aug, sub_aug):
    max_sent_id = get_max_sent_id(dataset)
    for image in tqdm(dataset['images']):
        new_image_sentences = []
        new_sentids = []
        for sentence in image['sentences']:
            new_image_sentences.append(sentence)
            new_sentids.append(sentence['sentid'])
            if image['split'] != 'train':
              continue
            aug_variants = augment_sentence(sentence, ins_aug, sub_aug)
            for variant in aug_variants:
                dataset_sentence = construct_dataset_sentence(variant, sentence.copy(), max_sent_id)
                new_image_sentences.append(dataset_sentence)
                new_sentids.append(dataset_sentence['sentid'])
                max_sent_id += 1
        image['sentences'] = new_image_sentences
        image['sentids'] = new_sentids
    return dataset

captions = {}
with open('/mnt/disks/disk1/COCO/dataset_coco.json') as f:
    captions = json.load(f)

coco_new = augment_dataset(captions, ins_aug, sub_aug)
with open('/mnt/disks/disk1/COCO/dataset_coco_synonyms_bert2_p06.json', 'w') as f:
    f.write(json.dumps(coco_new))
