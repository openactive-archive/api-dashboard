###python 3

def flatten (data, prefix = None):
    # iterate all items


    for item in data:
        # split the object
        flat, key, subs = splitObj(item, prefix)
        if subs is None:
            if key is None:
                yield flat
                continue
        # just return fully flat objects
        if key is None and flat is not None:
            yield flat
            continue

        # otherwise recursively flatten the subobjects
        try:
            for sub in flatten(subs, key):
                if flat is not None:
                    sub.update(flat)
                yield sub
        except TypeError as e:
            # custLog.logger.error("ERR: TypeError"+str(e))
            print(e)


def splitObj (obj, prefix = None):

    # copy the object, optionally add the prefix before each key
    new = obj.copy() if prefix is None or prefix=="NotFlat" else {'{}_{}'.format(prefix, k): v for k, v in obj.items() }

    cL = 0
    cD = 0
    # try to find the key holding the subobject or a list of subobjects
    for k, v in new.items():
        #Determine the number of lists in v
        if isinstance(v, list):
            cL += 1
        #Determine the number of dict in v
        elif isinstance(v, dict):
            cD += 1
    for k, v in new.items():
        # list of subobjects
        if isinstance(v, list):
            if (cD+cL) <=1:
                try:
                    type(v[0])
                except IndexError:
                    v = [""]
                if not isinstance(v[0], str):
                    del new[k]
                    return new, k, v
                elif isinstance(v[0], str):

                    new[k] = ", ".join(v)
                    return new, None, None
                else:
                    # custLog.logger.info("")
                    print('wrong')
            elif (cD+cL) >1:

                try:
                    type(v[0])
                except IndexError:
                    v = [""]

                if not isinstance(v[0], str):
                    del new[k]
                    for x in flatten([new]):
                        newOut = x
                        break
                    return newOut, k, v
                elif isinstance(v[0], str):
                    new[k] = ", ".join(v)
                    return None, "NotFlat", [new]
                else:
                    print('sbagliato')

        # or just one subobject
        elif isinstance(v, dict):
            if (cD+cL) <=1:
                del new[k]
                return new, k, [v]
            elif (cD+cL) >1:
                del new[k]
                for x in flatten([new]):
                    newOut = x
                    break
                return newOut, k, [v]
    return new, None, None
