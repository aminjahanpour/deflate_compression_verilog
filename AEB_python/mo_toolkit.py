import numpy as np
from scipy.spatial import ConvexHull
from math import *
from scipy import spatial
import copy
from pymoo.interface import crossover, mutation
from pymoo.factory import get_crossover, get_mutation
# import evo_generic

obj_val_precision = 7

def callqhull(points):
    hull = ConvexHull(points)
    qhullVolume = hull.volume
    facets_vertices = hull.simplices + 1.0
    facets_norm = np.delete(hull.equations, np.s_[-1:], 1)

    return [qhullVolume, facets_vertices, facets_norm]


def ismember(a, b):
    bind = {}
    for i, elt in enumerate(b):
        if elt not in bind:
            bind[elt] = i
    return [bind.get(itm, None) for itm in a]


def chc(points):

    if (points.shape[0] <= points.shape[1] + 1) or (points.shape[0] < 4): return points.shape[0] * [1.0]

    CHC_metric = np.zeros((points.shape[0]))

    Totalv, facets_vertices, facets_norm = callqhull(points)

    if isinstance(Totalv, (int, float, complex)) == False: return points.shape[0] * [1.0]

    dims = facets_vertices.shape[1]

    all_CHpts_ind = np.unique(facets_vertices)

    ZEROind = (all_CHpts_ind == 0)

    for i in range(ZEROind.size - 1, -1, -1):
        if ZEROind[i] == True:
            all_CHpts_ind = np.delete(all_CHpts_ind, i)

    # Identify points in groups ii, iii, iv as defined above
    top_facets_ind = (
                np.amin(facets_norm, axis=1) >= 0)  # facets with outward norm that has only non-negative components
    temp = np.zeros((0, dims))
    for i in range(0, top_facets_ind.size):
        if top_facets_ind[i] == True:
            temp = np.append(temp, [facets_vertices[i][:]], 0)
    ii_iv_CHpts_ind = np.unique(temp)  # points on top of CH, i.e.  groups ii and iv
    ZEROind = (ii_iv_CHpts_ind == 0)

    for i in range(ZEROind.size - 1, -1, -1):
        if ZEROind[i] == True:
            ii_iv_CHpts_ind = np.delete(ii_iv_CHpts_ind, i)

    other_facets_ind = range(1, facets_norm.shape[0] + 1)

    for i in range(top_facets_ind.size - 1, -1, -1):
        if top_facets_ind[i] == True:
            other_facets_ind = np.delete(other_facets_ind, i)

    temp2 = np.zeros((0, dims))
    for i in other_facets_ind:
        temp2 = np.append(temp2, [facets_vertices[i - 1][:]], 0)
    iii_iv_CHpts_ind = np.unique(temp2)  # points on top of CH, i.e.  groups ii and iv
    ZEROind = (iii_iv_CHpts_ind == 0)

    for i in range(ZEROind.size - 1, -1, -1):
        if ZEROind[i] == True:
            iii_iv_CHpts_ind = np.delete(iii_iv_CHpts_ind, i)

    bor_ind = np.array(ismember(iii_iv_CHpts_ind, ii_iv_CHpts_ind))

    for i in range(0, bor_ind.size):
        if bor_ind[i] == None:
            bor_ind[i] = 0
        else:
            bor_ind[i] = 1

    bor_CHpts_ind = np.zeros(0)
    for i in range(bor_ind.shape[0]):
        if bor_ind[i] == 1:
            bor_CHpts_ind = np.append(bor_CHpts_ind, [iii_iv_CHpts_ind[i]], 0)

    bor_CHpts_ind = bor_CHpts_ind.astype(int)

    bot_CHpts_ind = iii_iv_CHpts_ind

    bot_CHpts_ind = bot_CHpts_ind.astype(int)

    # bot_CHpts_ind(bor_ind) = []
    for i in range(bor_ind.size - 1, -1, -1):
        if bor_ind[i] == True:
            bot_CHpts_ind = np.delete(bot_CHpts_ind, i)

    # When number of bottom points and border points are not enough to form CH
    if bot_CHpts_ind.size == 0: return points.shape[0] * [1.0]

    all_CHpts_ind = all_CHpts_ind.astype(int)

    # Convex Hull Contribution Calculation
    for i in range(0, bot_CHpts_ind.size):
        y = points[all_CHpts_ind - 1][:]
        ind = np.array(ismember(all_CHpts_ind, [bot_CHpts_ind[i]]))
        for j in range(0, ind.size):
            if ind[j] == None:
                ind[j] = 0
            else:
                ind[j] = 1

        yy = np.zeros((0, points.shape[1]))

        for j in range(y.shape[0]):
            if ind[j] == 0:
                yy = np.append(yy, [y[j][:]], 0)
        y = yy

        # nothing, Sub_v = convhulln( y )
        if y.shape[0] <= 2: return points.shape[0] * [1.0]

        if y.shape[0] < 4: return points.shape[0] * [1.0]

        Sub_v, facets_vertices, facets_norm = callqhull(y)

        if isinstance(Sub_v, (int, float, complex)) == False: return points.shape[0] * [
            1.0]  # if error occurs##############################

        CHC_metric[bot_CHpts_ind[i] - 1] = float(Totalv) - float(Sub_v)

    if max(CHC_metric) == 0: return points.shape[0] * [1.0]  # In case no solution has valid CHC value

    Y = points[bor_CHpts_ind - 1][:]
    X = points[bot_CHpts_ind - 1][:]
    IDX = np.zeros(Y.shape[0], dtype=np.int32)
    tree = spatial.cKDTree(X)
    for i in range(Y.shape[0]):
        IDX[i] = int(tree.query(Y[i])[-1] + 1)
    for i in range(bor_CHpts_ind.shape[0]):
        CHC_metric[bor_CHpts_ind[i] - 1] = CHC_metric[bot_CHpts_ind[IDX[i] - 1] - 1]

    return CHC_metric


def cd(in_ar):

    dataNumber = in_ar.shape[0]
    num_objs = in_ar.shape[1]

    cd_value = in_ar.shape[0] * [0.0]

    z_value = in_ar.shape[0] * [0.0]

    for obj in range(0, num_objs):
        # sort in_ar by the obj
        in_ar_sort_idx = in_ar[:, obj].argsort()
        in_ar = in_ar[in_ar_sort_idx]


        # CD value for a solution is gradually produced per objective
        for i in range(0, dataNumber):
            if i == 0:
                z_value[i] = np.abs(in_ar[i + 1, obj] - in_ar[i, obj])
            elif i == dataNumber - 1:
                z_value[i] = np.abs(in_ar[i, obj] - in_ar[i - 1, obj])
            else:
                z_value[i] = np.abs(in_ar[i + 1, obj] - in_ar[i - 1, obj])

            cd_value[in_ar_sort_idx[i]] += z_value[i]

    return cd_value


class HyperVolume:
    """
    Hypervolume computation based on variant 3 of the algorithm in the paper:
    C. M. Fonseca, L. Paquete, and M. Lopez-Ibanez. An improved dimension-sweep
    algorithm for the hypervolume indicator. In IEEE Congress on Evolutionary
    Computation, pages 1157-1163, Vancouver, Canada, July 2006.

    Minimization is implicitly assumed here!

    """

    def __init__(self, referencePoint):
        """Constructor."""
        self.referencePoint = referencePoint
        self.list = []

    def compute(self, front):
        """Returns the hypervolume that is dominated by a non-dominated front.

        Before the HV computation, front and reference point are translated, so
        that the reference point is [0, ..., 0].

        """

        def weaklyDominates(point, other):
            for i in range(len(point)):
                if point[i] > other[i]:
                    return False
            return True

        relevantPoints = []
        referencePoint = self.referencePoint
        dimensions = len(referencePoint)
        for point in front:
            # only consider points that dominate the reference point
            if weaklyDominates(point, referencePoint):
                relevantPoints.append(point)
        if any(referencePoint):
            # shift points so that referencePoint == [0, ..., 0]
            # this way the reference point doesn't have to be explicitly used
            # in the HV computation
            for j in range(len(relevantPoints)):
                relevantPoints[j] = [relevantPoints[j][i] - referencePoint[i] for i in range(dimensions)]
        self.preProcess(relevantPoints)
        bounds = [-1.0e308] * dimensions
        hyperVolume = self.hvRecursive(dimensions - 1, len(relevantPoints), bounds)
        return hyperVolume

    def hvRecursive(self, dimIndex, length, bounds):
        """Recursive call to hypervolume calculation.

        In contrast to the paper, the code assumes that the reference point
        is [0, ..., 0]. This allows the avoidance of a few operations.

        """
        hvol = 0.0
        sentinel = self.list.sentinel
        if length == 0:
            return hvol
        elif dimIndex == 0:
            # special case: only one dimension
            # why using hypervolume at all?
            return -sentinel.next[0].cargo[0]
        elif dimIndex == 1:
            # special case: two dimensions, end recursion
            q = sentinel.next[1]
            h = q.cargo[0]
            p = q.next[1]
            while p is not sentinel:
                pCargo = p.cargo
                hvol += h * (q.cargo[1] - pCargo[1])
                if pCargo[0] < h:
                    h = pCargo[0]
                q = p
                p = q.next[1]
            hvol += h * q.cargo[1]
            return hvol
        else:
            remove = self.list.remove
            reinsert = self.list.reinsert
            hvRecursive = self.hvRecursive
            p = sentinel
            q = p.prev[dimIndex]
            while q.cargo != None:
                if q.ignore < dimIndex:
                    q.ignore = 0
                q = q.prev[dimIndex]
            q = p.prev[dimIndex]
            while length > 1 and (
                    q.cargo[dimIndex] > bounds[dimIndex] or q.prev[dimIndex].cargo[dimIndex] >= bounds[dimIndex]):
                p = q
                remove(p, dimIndex, bounds)
                q = p.prev[dimIndex]
                length -= 1
            qArea = q.area
            qCargo = q.cargo
            qPrevDimIndex = q.prev[dimIndex]
            if length > 1:
                hvol = qPrevDimIndex.volume[dimIndex] + qPrevDimIndex.area[dimIndex] * (
                            qCargo[dimIndex] - qPrevDimIndex.cargo[dimIndex])
            else:
                qArea[0] = 1
                qArea[1:dimIndex + 1] = [qArea[i] * -qCargo[i] for i in range(dimIndex)]
            q.volume[dimIndex] = hvol
            if q.ignore >= dimIndex:
                qArea[dimIndex] = qPrevDimIndex.area[dimIndex]
            else:
                qArea[dimIndex] = hvRecursive(dimIndex - 1, length, bounds)
                if qArea[dimIndex] <= qPrevDimIndex.area[dimIndex]:
                    q.ignore = dimIndex
            while p is not sentinel:
                pCargoDimIndex = p.cargo[dimIndex]
                hvol += q.area[dimIndex] * (pCargoDimIndex - q.cargo[dimIndex])
                bounds[dimIndex] = pCargoDimIndex
                reinsert(p, dimIndex, bounds)
                length += 1
                q = p
                p = p.next[dimIndex]
                q.volume[dimIndex] = hvol
                if q.ignore >= dimIndex:
                    q.area[dimIndex] = q.prev[dimIndex].area[dimIndex]
                else:
                    q.area[dimIndex] = hvRecursive(dimIndex - 1, length, bounds)
                    if q.area[dimIndex] <= q.prev[dimIndex].area[dimIndex]:
                        q.ignore = dimIndex
            hvol -= q.area[dimIndex] * q.cargo[dimIndex]
            return hvol

    def preProcess(self, front):
        """Sets up the list data structure needed for calculation."""
        dimensions = len(self.referencePoint)
        nodeList = MultiList(dimensions)
        nodes = [MultiList.Node(dimensions, point) for point in front]
        for i in range(dimensions):
            self.sortByDimension(nodes, i)
            nodeList.extend(nodes, i)
        self.list = nodeList

    def sortByDimension(self, nodes, i):
        """Sorts the list of nodes by the i-th value of the contained points."""
        # build a list of tuples of (point[i], node)
        decorated = [(node.cargo[i], node) for node in nodes]
        # sort by this value
        decorated.sort()
        # write back to original list
        nodes[:]= [node for (_, node) in decorated]


class MultiList:
    """A special data structure needed by FonsecaHyperVolume.

    It consists of several doubly linked lists that share common nodes. So,
    every node has multiple predecessors and successors, one in every list.

    """

    class Node:

        def __init__(self, numberLists, cargo=None):
            self.cargo = cargo
            self.next = [None] * numberLists
            self.prev = [None] * numberLists
            self.ignore = 0
            self.area = [0.0] * numberLists
            self.volume = [0.0] * numberLists

        def __str__(self):
            return str(self.cargo)

    def __init__(self, numberLists):
        """Constructor.

        Builds 'numberLists' doubly linked lists.

        """
        self.numberLists = numberLists
        self.sentinel = MultiList.Node(numberLists)
        self.sentinel.next = [self.sentinel] * numberLists
        self.sentinel.prev = [self.sentinel] * numberLists

    def __str__(self):
        strings = []
        for i in range(self.numberLists):
            currentList = []
            node = self.sentinel.next[i]
            while node != self.sentinel:
                currentList.append(str(node))
                node = node.next[i]
            strings.append(str(currentList))
        stringRepr = ""
        for string in strings:
            stringRepr += string + "\n"
        return stringRepr

    def __len__(self):
        """Returns the number of lists that are included in this MultiList."""
        return self.numberLists

    def getLength(self, i):
        """Returns the length of the i-th list."""
        length = 0
        sentinel = self.sentinel
        node = sentinel.next[i]
        while node != sentinel:
            length += 1
            node = node.next[i]
        return length

    def append(self, node, index):
        """Appends a node to the end of the list at the given index."""
        lastButOne = self.sentinel.prev[index]
        node.next[index] = self.sentinel
        node.prev[index] = lastButOne
        # set the last element as the new one
        self.sentinel.prev[index] = node
        lastButOne.next[index] = node

    def extend(self, nodes, index):
        """Extends the list at the given index with the nodes."""
        sentinel = self.sentinel
        for node in nodes:
            lastButOne = sentinel.prev[index]
            node.next[index] = sentinel
            node.prev[index] = lastButOne
            # set the last element as the new one
            sentinel.prev[index] = node
            lastButOne.next[index] = node

    def remove(self, node, index, bounds):
        """Removes and returns 'node' from all lists in [0, 'index'[."""
        for i in range(index):
            predecessor = node.prev[i]
            successor = node.next[i]
            predecessor.next[i] = successor
            successor.prev[i] = predecessor
            if bounds[i] > node.cargo[i]:
                bounds[i] = node.cargo[i]
        return node

    def reinsert(self, node, index, bounds):
        """
        Inserts 'node' at the position it had in all lists in [0, 'index'[
        before it was removed. This method assumes that the next and previous
        nodes of the node that is reinserted are in the list.

        """
        for i in range(index):
            node.prev[i].next[i] = node
            node.next[i].prev[i] = node
            if bounds[i] > node.cargo[i]:
                bounds[i] = node.cargo[i]


def HVV(ref, front):

    hyperVolume = HyperVolume(ref)
    result = hyperVolume.compute(front)

    return float(result)


def hvc(in_ar):

    dataNumber = in_ar.shape[0]
    num_objs = in_ar.shape[1]

    refPoint = [1.0] * num_objs

    hvc_value = in_ar.shape[0] * [0.0]

    # Only for bi-objective problems -Only works for a non-dominated sorted set of solutions

    # sort points by first obj. value
    in_ar_sort_idx = in_ar[:,0].argsort()
    in_ar = in_ar[in_ar_sort_idx]

    z_value = in_ar.shape[0] * [0.0]

    for i in range(1, dataNumber - 1):
        z_value[i] = (in_ar[i + 1, 0] - in_ar[i, 0]) * (in_ar[i - 1, 1] - in_ar[i, 1])
        hvc_value[in_ar_sort_idx[i]] = z_value[i]

    # assigning the closest point z value to end points. - the same as MATLAB code.
    hvc_value[in_ar_sort_idx[0]] = z_value[1] # in_ar_sort_idx[0] --> index of the smallest
    hvc_value[in_ar_sort_idx[-1]] = z_value[-2]


    return hvc_value


class solution:
    def __init__(self, decnum, objnum):
        self.dv = np.empty(decnum, np.float64)
        self.f = np.empty(objnum, np.float64)
        self.z = 0.0

        self.raw = 0.0
        self.density = 0.0
        self.fitness = 0.0
        self.lifetime = 1

        self.aux = 0.0
        self.psi = 0.0


def dominion_status(x1, x2):
    # non-domination
    ds = 0

    # x1 dominates x2
    if all(round(x, obj_val_precision) <= round(y, obj_val_precision) for x, y in zip(x1.f, x2.f)):
        ds = 1

    # x2 dominates x1
    elif all(round(x, obj_val_precision) <= round(y, obj_val_precision) for x, y in zip(x2.f, x1.f)):
        ds = 2
    return ds


def neigh_value_continuous(s, r, norm_rnd, unif_rnd):
    snew = s + norm_rnd * r

    if snew < 0.:
        if unif_rnd <= 0.5:
            snew = -1. * snew
        else:
            snew = 0.0
        if snew > 1.0:
            snew = 0.0
    elif snew > 1.0:
        if (unif_rnd <= 0.5):
            snew = 1.0 - (snew - 1.0)
        else:
            snew = 1.0
        if (snew < 0.0):
            snew = 1.0
    return snew

    # if snew < 0.0:
    #     if snew > -1.0:
    #         return np.random.random() * (-snew)
    #     return np.random.random()
    #
    # if snew > 1.0:
    #     if snew < 2.0:
    #         return 1.0 - np.random.random() * (snew - 1.0)
    #     return np.random.random()
    # return snew

def Sel_solution(Archive):
    Z = [ff.z for ff in Archive]
    SZ =sum(Z)
    if SZ != 0.0:
        sbest_idx = np.random.choice(list(range(len(Z))), 1, p=[k / SZ for k in Z])[0]
    else:
        sbest_idx = 0
    sbest = Archive[sbest_idx]
    return sbest_idx, sbest

def Update_Archive(archive, candidate):
    list_of_items_to_be_removed = []
    dominance_flag = 0
    for i in range(0, len(archive)):
        dominion_status_result = dominion_status(candidate, archive[i])
        if (dominion_status_result == 2):  # //candidate is dominated
            dominance_flag = -1
            return archive, dominance_flag
        elif dominion_status_result == 1:
            list_of_items_to_be_removed.append(i)

    archive = [i for j, i in enumerate(archive) if j not in list_of_items_to_be_removed]
    archive.append(candidate)
    return archive, dominance_flag


def dominance_probability(a, b, delta):
    """
    the probability of a domination b
    delta is half uncertainty range size for both a and b
    """
    # a.f = [0,0]
    # b.f = [2.9,2.9]
    # delta = 1*1.5

    # print(a.f[0], a.f[1])
    # print(b.f[0], b.f[1])


    m = len(a.f)

    a_L = np.empty(shape=(m))
    a_U = np.empty(shape=(m))
    b_L = np.empty(shape=(m))
    b_U = np.empty(shape=(m))

    for i in range(m):
        a_L[i] = a.f[i] - delta
        a_U[i] = a.f[i] + delta
        b_L[i] = b.f[i] - delta
        b_U[i] = b.f[i] + delta


    P = 1.0

    for i in range(m):
        if a.f[i] > b.f[i] + 2. * delta:
            # proof from this objective alone is enough to show that there is no chance `a` could dominate `b`
            P = 0.0
            break

        elif a.f[i] < b.f[i] - 2. * delta:
            # this objective matched the hypothesis of `a` dominating `b` so continue checking other objectives
            continue

        else:
            p = (1./(2*delta)) * (b.f[i] - a.f[i] + delta) + (1./(8. * pow(delta, 2))) * np.sign(a.f[i] - b.f[i]) * pow(a.f[i] - b.f[i] ,2)
            P = P * p

    return P


def dominion_status_NT(candidate, archived_sol, delta, alpha):

    p1 = dominance_probability(candidate, archived_sol, delta)
    p2 = dominance_probability(archived_sol, candidate, delta)


    # if p1 < (1. - alpha) and p2 < (1. - alpha):
    #     ds = 0
    #
    # elif p1 < (1. - alpha) and p2 >= alpha:
    #     ds = 2
    #
    # elif p1 >= alpha and p2 < (1. - alpha):
    #     ds = 1
    #
    # else:
    #     print('this can not happen! *************************************************************************************************************************************************************************************************************************************************************')
    #     assert False


    ds = 2

    if p1 > alpha and p2 >= 0:
        ds = 1

    if p1 < (1. - alpha) and p2 < (1. - alpha):
        ds = 0

    return ds


def Update_Archive_NT(archive, candidate, delta, alpha):
    # noise tolerant
    list_of_items_to_be_removed = []
    dominance_flag = 0
    for i in range(0, len(archive)):
        dominion_status_result = dominion_status_NT(candidate, archive[i], delta, alpha)
        if (dominion_status_result == 2):  # //candidate is dominated
            dominance_flag = -1
            return archive, dominance_flag
        elif dominion_status_result == 1:
            list_of_items_to_be_removed.append(i)

    archive = [i for j, i in enumerate(archive) if j not in list_of_items_to_be_removed]
    archive.append(candidate)
    return archive, dominance_flag


def Calc_Z(archive, Select_metric):
    if len(archive) <= 2:
        for sol in archive:
            sol.z = 0.0
            return archive


    # bulit normalized in_ar
    num_objs = len(archive[0].f)
    in_ar = np.zeros((len(archive), num_objs))
    for j in range(num_objs):
        min_obj = min(archive, key=lambda x: x.f[j]).f[j]
        max_obj = max(archive, key=lambda x: x.f[j]).f[j]
        for i in range(in_ar.shape[0]):
            in_ar[i, j] = 1.0 * (archive[i].f[j] - min_obj) / (max_obj - min_obj)
            if np.isnan(in_ar[i, j]):
                in_ar[i, j] = 0.5


    if Select_metric == 0:  # unity
        z = [1.0] * len(archive)

    elif Select_metric == 1:  # CD - endpoints get not less than nearest
        z = cd(in_ar)

    elif Select_metric == 2:  # HVC_EXACT - end points only for 2D!!!
        z = hvc(in_ar)

    elif Select_metric == 3:  # CHC - endpoints get nearest non-zero value
        z = chc(in_ar)



    for i in range(len(archive)):
        archive[i].z = z[i]

    # assert all(np.asarray(z) > 0)

    return archive


def strength(sj, union):
    """
    strength of sj is the number of solutions in union that sj dominates
    """
    res = 0
    for i in range(len(union)):
        dominion_status_result = dominion_status(sj, union[i])
        if (dominion_status_result == 1):
            res += 1

    return res


def CalculateRawFitness(sk, union):
    """
    this function calculates the raw fitness of sk as the sum of the strength values of the solutions
     in union that dominate sk.
    """
    res = 0
    for i in range(len(union)):
        dominion_status_result = dominion_status(sk, union[i])
        if (dominion_status_result == 2):
            res += strength(union[i], union)

    return res

def CalculateSolutionDensity(si, union):
    dist = []
    for sol in union:
        dist.append(np.linalg.norm(si.f - sol.f))
    k = int(sqrt(len(union)))
    sigma_dist = sorted(dist)[k]
    density = 1.0 / (sigma_dist + 2.0)

    return density

def GetNonDominated(union):
    list_of_items_to_be_removed = []

    for j, candidate in enumerate(union):
        # get rid of whoever dominated by candidate

        if j not in list_of_items_to_be_removed:

            for i in range(len(union)):
                if i != j:
                    dominion_status_result = dominion_status(candidate, union[i])
                    if dominion_status_result == 1:
                        list_of_items_to_be_removed.append(i)

    union = [i for j, i in enumerate(union) if j not in list_of_items_to_be_removed]

    return union


def PopulateWithRemainingBest(union, archive, archive_size):
    to_be_added_count = archive_size - len(archive)
    arg_sort = np.argsort([x.fitness for x in union])
    for i in range(to_be_added_count):
        archive.append(union[arg_sort[i]])

    return archive


def RemoveMostSimilar(archive, archive_size):
    to_be_removed_count = len(archive) - archive_size
    densities = []
    for sol in archive:

        densities.append(CalculateSolutionDensity(sol, archive))

    arg_max = np.argmax(densities)

    archive = [i for j, i in enumerate(archive) if j not in arg_max[:to_be_removed_count]]

    return archive

def SelectParents(Union, population_size):
    assert population_size <= len(Union)
    f_list = [sol.fitness for sol in Union]
    selection_count = population_size
    selected_idx = evo_generic.ga_selection(f_list, selection_count, 'top', 0)
    return selected_idx

def CrossoverAndMutation(union, selected_idx, population_size, eta_cross, eta_mut):
    cx_m, cx_p = 'sbx', eta_cross
    mut_mu, mut_m, mut_p = eta_mut, 'poly', 0.01

    M = len(selected_idx)
    num_objs = len(union[0].f)
    dim = len(union[0].dv)

    couples_list = np.random.permutation(selected_idx).reshape((int(M / 2), 2))

    children = []

    for parents_idx, parents in enumerate(couples_list):

        mom = list(union[parents[0]].dv)
        dad = list(union[parents[1]].dv)

        son, daughter = evo_generic.ga_crossover(mom,
                                                dad,
                                                cx_m,
                                                cx_p
                                                )

        son_mut = evo_generic.ga_mutation(son, mut_mu, mut_m, mut_p)
        daughter_mut = evo_generic.ga_mutation(daughter, mut_mu, mut_m, mut_p)

        child1 = solution(dim, num_objs)
        child1.dv = son_mut

        child2 = solution(dim, num_objs)
        child2.dv = daughter_mut

        children.append(child1)
        children.append(child2)

    return children



def CrossoverAndMutationPyMoo(union, selected_idx, population_size, eta_cross, eta_mut):
    dim = len(union[0].dv)

    moms=np.empty(shape=(int(0.5*len(selected_idx)), dim))
    dads=np.empty(shape=(int(0.5*len(selected_idx)), dim))

    M = len(selected_idx)
    num_objs = len(union[0].f)

    couples_list = np.random.permutation(selected_idx).reshape((int(M / 2), 2))

    children = []

    for parents_idx, parents in enumerate(couples_list):

        moms[parents_idx] = list(union[parents[0]].dv)
        dads[parents_idx] = list(union[parents[1]].dv)

    off = crossover(get_crossover("real_sbx", prob=0.9, eta=eta_cross, prob_per_variable=1.0), moms, dads)
    off_mut = mutation(get_mutation("real_pm", eta=eta_mut, prob=1.0), off)

    for el in off_mut:
        pass
        child1 = solution(dim, num_objs)
        child1.dv = el
        children.append(child1)

    return children



def compute_lifetime(dominating_fraction,c1, c2, k_max):

    if dominating_fraction < c1:
        k = k_max
    elif dominating_fraction > c2:
        k = 1
    else:
        k = int(k_max - (dominating_fraction - c1) * (k_max - 1.) / (c2 - c1))

    return k


def update_lifetime(population, archive, c1, c2, k_max):
    """
    if archive is empty, kmax is assigned

    """

    for idx, population_solution in enumerate(population):
        dominating_fraction = 0.
        if len(archive) > 0:

            for archive_solution in archive:
                dominion_status_result = dominion_status(population_solution, archive_solution)
                if dominion_status_result == 1:
                    dominating_fraction += 1.

            dominating_fraction = dominating_fraction / len(archive)
        population[idx].lifetime = compute_lifetime(dominating_fraction, c1, c2, k_max)


    return population


def not_expired_solutions(union):
    return [el for el in union if el.lifetime > 0]


def re_evaluation(population, archive):
    for sol in archive:
        if sol.lifetime == 0:
            population.append(copy.deepcopy(sol))
    return population


def age_archive(archive):

    for i in range(len(archive)):
        archive[i].lifetime = archive[i].lifetime - 1

    return archive

def print_archive(archive):
    import pandas as pd

    dim=len(archive[0].dv)
    num_obj=len(archive[0].f)
    data = {}

    for dv_idx in range(dim):
        data['dv_%i' % dv_idx] = [el.dv[dv_idx] for el in archive]

    for f_idx in range(num_obj):
        data['f_%i' % f_idx] = [el.f[f_idx] for el in archive]

    data['aux'] = [el.aux for el in archive]

    df = pd.DataFrame(data)
    df = df.sort_values(by=['f_0'])

    df.to_csv('archive_out.csv')


    ans = """"""
    for el in archive:
        ans += '%8.5f, %8.5f, %8.5f, %8.5f, %i\n' % (el.dv[0], el.dv[1], el.f[0], el.f[1], el.lifetime)

    return ans



def denoise_archive(archive, opt_settings, k):
    from tqdm import tqdm
    from factory import evo_problem
    problem = evo_problem(model_id=opt_settings["model_id"],
                          num_dec=opt_settings["dim"],
                          num_objs=opt_settings['num_objs'],
                          opt_settings=opt_settings)

    F = problem.evaluate

    ar=[]

    for i in tqdm(range(len(archive))):
        f1 = []
        f2 = []
        for j in range(k):
            if 'vqs' in opt_settings['model_id']:

                gg, fidel = F(archive[i].dv)
                f1.append(gg[0])
                f2.append(gg[1])
            else:
                gg = F(archive[i].dv)
                f1.append(gg[0])
                f2.append(gg[1])

        ar.append([np.mean(f1), np.mean(f2)])

    return ar

def plot_denoised_archive(archive, opt_settings, k):
    import matplotlib.pyplot as plt
    fig = plt.figure(constrained_layout=True)

    archive2 = denoise_archive(archive, opt_settings, k)

    source_f1 = []
    source_f2 = []

    target_f1 = []
    target_f2 = []

    for (el1, el2) in zip(archive, archive2):
        source_f1.append(el1.f[0])
        source_f2.append(el1.f[1])

        target_f1.append(el2[0])
        target_f2.append(el2[1])

        plt.arrow(el1.f[0], el1.f[1], el2[0]-el1.f[0], el2[1]-el1.f[1], length_includes_head = True)
                  # head_width=.04, width=0.00001, head_length=0.03)

    plt.scatter(x=source_f1, y=source_f2, c='r',  label='noisy')
    plt.scatter(x=target_f1, y=target_f2, c='g',  label='denoised')

    if 'family_energy_on_GS_of_Ht' in opt_settings:
        plt.scatter(x=opt_settings['family_energy_on_GS_of_Ht'][0], y=sum(opt_settings['family_energy_on_GS_of_Ht'][1:]), c='y', label='utopia')

    fidelities = [round(x.aux, 2) for x in archive]

    for i, txt in enumerate(fidelities):
        fig.axes[0].annotate(txt, (target_f1[i]+.1, target_f2[i]), fontsize=8)



    plt.legend()
    plt.show()
    return archive


def plot_archive(archive, label=None):
    import matplotlib.pyplot as plt
    import pandas as pd
    import seaborn as sns
    sns.set()

    f1=[]
    f2=[]
    for el in archive:
        f1.append(el.f[0])
        f2.append(el.f[1])
    sns.scatterplot(f1,f2)
    if not label is None:
        plt.title(label)
    plt.show()


def solution_exists_in_archive(sol, archive):
    for archive_sol in archive:
        if max([abs(x-y) for (x, y) in zip(sol.dv, archive_sol.dv)]) < 0.000001:
            return True
    return False