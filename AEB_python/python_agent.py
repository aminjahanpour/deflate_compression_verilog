import numpy as np
import requests
import json
import math
from math import cos, pi, exp, e, sqrt, sin

"""
This is the Ackley test function with -15. < x < 30.
Replace with your ouw cost function and update the bounds accordingly


A-1 , wr
A-2 , wr
A-2 , A-2-sub , wr
B , wr


warapping

"""
# def obj_fun(individual, lower_bound=-15., upper_bound=30.):
def obj_fun(individual, lower_bound=0., upper_bound=1.):

    # this line is necessary to denormalize the decision variables
    individual = [x * (upper_bound - lower_bound) + lower_bound for x in individual]


    # N = len(individual)
    # return  individual[0] * sin(100*individual[0])

    # y = 0
    # for k in [1, 2, 3, 4, 5, 6]:
    #     y = y + k * sin((k+1) * (100.*individual[0]) + k)
    # return y

    # return (1. - 3.5 * individual[0]) * sin(38.0 * individual[0])
    # return ((individual[0] - 0.75) ** 2) * ((individual[0] + 1) / 5) + 0.1


    # return 20 - 20 * exp(-0.2 * sqrt(1.0 / N * sum(x ** 2 for x in individual))) \
    #        + e - exp(1.0 / N * sum(cos(2 * pi * x) for x in individual))

    # ZDT1 - Zitzler, Deb, and Thiele (2000)
    # bi-objective
    # 30 DVs
    # m = 30, 0<=xi<=1
    # optimal Pareto-front: gx=1

    m = len(individual)
    f1 = individual[0]
    gx = 1.0 + 9.0 * sum([individual[i]/(m-1) for i in range(1, m)])
    h_f1_gx = 1.0 - math.pow((f1/gx) , 0.5)
    f2 = gx * h_f1_gx

    return f1


# server = 'http://35.203.55.211/'

# gcp Zurich
# server = 'http://34.65.208.20/'

server = 'http://127.0.0.1:5000/'

key = 'email mjahanpo@uwaterloo.ca for a key'
key = '0d80c5a7740ac8ff2fc29dc4a5d791b400161b21'

dim = int(2)
budget = int(200)
id = 'dd'
piac = 0
if piac:
    budget += 50 * dim

initial=str(dim*[0.5])
initial = ''

num_objs = 1

def perform():
    resp = requests.post(url='%s?key=%s&req=del&id=%s' % (server, key, id))
    print(resp.content)

    resp = requests.post(url='%s?key=%s&req=create&id=%s&dim=%s&budget=%s&piac=%s&initial=%s&num_objs=%s' % (server, key, id, dim, budget, piac, initial, num_objs))
    # resp = requests.post(url='%s?key=%s&req=create&id=%s&dim=%s&budget=%s' % (server, key, id, dim, budget))

    print(resp.content)

    resp = requests.post(url='%s?key=%s&req=ask&id=%s' % (server, key, id))
    print(resp.content)


    f_best = 10e20
    counter = 0
    while b'budget_used_up' not in resp.content:
        dv = json.loads(resp.content.decode("utf-8"))["dv"]

        # creating the vector of objective functions from recoeved solutions
        f = np.array(list(map(obj_fun, dv)))

        if num_objs == 1:
            # updating the best objective function (for logging only)
            if min(f) <= f_best: #update f_best and x_best
                f_best = min(f)
                x_best = dv[list(f).index(min(f))]

            f_arrstr = np.char.mod('[%f]', f)
            f_string = ";".join(f_arrstr)         # '[1.2];[1.3]'
            print("progress: %s   f_best:%f" % (round(100. * counter / budget, 0), f_best))

        else:
            f_arrstr = [str(list(x)) for x in f]
            f_string = ";".join(f_arrstr)        # '[1.2,6.5];[1.3, 1.2]'
            print("progress: %s " % (round(100. * counter / budget, 2)))

        payload = {'req': 'roll',
                   'key': key,
                   'id': id,
                   'dim': dim,
                   'f': f_string
                   }

        resp = requests.post(url=server, json=payload)
        print(resp.content)

        counter += len(dv)


    resp = requests.post(url='%s?key=%s&req=results&id=%s' % (server, key, id))
    print(resp.content)

    # f=json.loads(resp.content.decode("utf-8"))["best_f"]
    # import matplotlib.pyplot as plt
    # plt.scatter(x=[x[0] for x in f], y=[x[1] for x in f])
    # plt.show()

    # from mo_toolkit import HVV
    # hvv = HVV([1.,1.], f)
    # print(hvv)


# def analyse_api():
#     all_res = []
#     from tqdm import tqdm
#     for i in tqdm(range(opt_settings['n_jobs'])):
#         all_res.append(perform())
#
#     toolkit.plot_hist(all_res)

if __name__ == '__main__':
    perform()
    # analyse_api()