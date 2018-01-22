package fr.skyost.timetable.utils;

import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

public class HashMultiMap<K, V> {

	private final HashMap<K, Set<V>> map = new HashMap<K, Set<V>>();

	public final Set<V> put(final K key, final V value) {
		final Set<V> values = map.containsKey(key) ? map.get(key) : new HashSet<V>();
		values.add(value);
		return map.put(key, values);
	}

	public final Set<V> get(final K key) {
		return map.get(key);
	}

	public final int size() {
		return map.size();
	}

	public final Set<K> getAllKeys() {
		return map.keySet();
	}

	public final Set<V> getAllValues() {
		final Set<V> values = new HashSet<>();
		for(final Map.Entry<K, Set<V>> entry : map.entrySet()) {
			values.addAll(entry.getValue());
		}
		return values;
	}

}
